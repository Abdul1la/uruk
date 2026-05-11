# Firebase / FCM connection — remaining steps

Everything in the Flutter app is wired. To finish, you only need to:

1. Create the Firebase project + apps.
2. Drop the two config files into the project.
3. Tell the backend how to send FCM messages.

---

## App identifiers (use these exactly)

| Platform | Bundle / Package ID |
|---|---|
| Android | `com.urukservices.app` |
| iOS | `com.urukservices.app` |

---

## 1. Firebase Console — one-time setup

1. Open <https://console.firebase.google.com> → **Add project** → name it `uruk-motors` (or anything).
2. Inside the project, click the **gear icon → Project settings → Your apps**.
3. **Add Android app**
   - Package name: `com.urukservices.app`
   - Download `google-services.json`
   - Save it as: `android/app/google-services.json`
4. **Add iOS app**
   - Bundle ID: `com.urukservices.app`
   - Download `GoogleService-Info.plist`
   - Open `ios/Runner.xcworkspace` in Xcode → drag the file into the **Runner** group → check **"Copy items if needed"** + **Runner** target.
   - Do **not** put the file there with Finder; it has to be added through Xcode so it's registered with the Runner target.
5. **iOS APNs key (required for iOS push to work at all)**
   - Apple Developer portal → **Certificates, Identifiers & Profiles → Keys → +**
   - Enable **Apple Push Notifications service (APNs)**, download the `.p8` file (one-time download — save it).
   - In Firebase Console → **Project settings → Cloud Messaging → Apple app configuration → APNs Authentication Key → Upload**
   - Paste the Key ID + your Team ID from the Apple Developer account.
6. **Xcode capability (iOS push won't deliver without this)**
   - Open `ios/Runner.xcworkspace` → select the **Runner** target → **Signing & Capabilities → + Capability** → add **Push Notifications**.
   - Add **Background Modes** capability and tick **Remote notifications** (the Info.plist entry is already in place; the capability turns on the entitlement).

---

## 2. Install + run

```bash
cd /Users/mak/flutter_projects/uruk-main
flutter pub get
cd ios && pod install && cd ..
flutter run
```

On first launch the app will:
- Request notification permission (iOS prompt, Android 13+ runtime prompt).
- Get an FCM token from `FirebaseMessaging.getToken()`.
- After login, POST it to `POST /devices/register { token, platform }`.

You can verify the token is flowing by adding `debugPrint` to `FcmService.tokenStream` or by tailing the backend log.

---

## 3. Backend contract

The Flutter app expects these endpoints (all under the existing JWT auth — the user id comes from the token):

### `POST /devices/register`
```json
{ "token": "<fcm_token>", "platform": "ios" | "android" }
```
Store one row per `(userId, token)`. Replace existing rows with the same token (token rotation).

### `POST /devices/unregister`
```json
{ "token": "<fcm_token>" }
```
Delete the row. Called on logout.

### Sending a push (server → FCM)

Use **FCM HTTP v1** with the Firebase Admin SDK or a service-account access token.

**Critical:** the app reads `data` payload fields, not `notification` ones, when building the in-app row. Always send a `data` block. Include `notification` too if you want a system banner when the app is killed.

```js
// Node.js example using firebase-admin
import admin from 'firebase-admin';
admin.initializeApp({ credential: admin.credential.applicationDefault() });

await admin.messaging().send({
  token: deviceToken, // OR `tokens: [...]` with sendEachForMulticast
  // System banner (shown by the OS when the app is in background/terminated)
  notification: {
    title: 'موعد الصيانة غداً',
    body: 'سيارتك جاهزة للاستلام عند الساعة 10 صباحًا',
  },
  // App-readable payload — every key is a STRING (FCM data is Map<String,String>)
  data: {
    id: 'notif_abc123',
    userId: 'user_42',
    title: 'موعد الصيانة غداً',
    body: 'سيارتك جاهزة للاستلام عند الساعة 10 صباحًا',
    type: 'appointment',          // payment | appointment | report | subscription | general
    actionRoute: '/appointments', // tapped → router.go(this)
    createdAt: '2026-05-07T12:00:00Z',
  },
  android: {
    priority: 'high',
    notification: {
      channelId: 'uruk_default_channel', // matches AndroidManifest + FcmService
    },
  },
  apns: {
    payload: {
      aps: {
        sound: 'default',
        'content-available': 1, // wakes app for silent data updates
      },
    },
  },
});
```

### Token cleanup

Delete a stored device token whenever FCM responds with:
- `messaging/registration-token-not-registered`
- `messaging/invalid-registration-token`

Otherwise you'll keep paying to push to dead devices and eventually get rate-limited.

---

## 4. How notifications behave in the app

| App state | What happens |
|---|---|
| **Foreground** | `FcmService` shows a heads-up banner via `flutter_local_notifications`, prepends a row to `AppProvider.notifications`, bumps `unreadCount`. Tapping the banner navigates to `data.actionRoute`. |
| **Background** | OS shows the system banner. Tap → app opens, `FirebaseMessaging.onMessageOpenedApp` fires, router goes to `data.actionRoute`. |
| **Terminated (cold start)** | OS shows the banner. Tap → app launches, `getInitialMessage()` returns the message, router navigates 250 ms after boot. |

Action routes that work today (must match `appRouter`):
`/home`, `/notifications`, `/payment`, `/appointments`, `/my-cars`, `/profile`, `/accidents`, `/accidents/<id>`, `/subscription`, `/support`.

---

## 5. Things you do **not** need to do

- ❌ `flutterfire configure` / generated `firebase_options.dart` — `Firebase.initializeApp()` reads from `google-services.json` / `GoogleService-Info.plist` directly, so the generated file is optional. Skip it unless you also want web push.
- ❌ Manual notification channel creation — `FcmService.init()` registers the `uruk_default_channel` channel on every cold start.
- ❌ Manual permission UI — `FcmService.init()` triggers the system prompt the first time.

---

## 6. Quick smoke test

1. Run the app and log in.
2. In Firebase Console → **Cloud Messaging → Send your first message**.
3. Target by FCM token (copy from device logs) or by app.
4. Add this in the **Additional options → Custom data**:
   - `actionRoute` = `/notifications`
   - `type` = `general`
   - `title` = (anything)
   - `body` = (anything)
5. Send. Verify:
   - Banner appears.
   - Bell badge ticks up.
   - Tap → opens the notifications screen.

If any of the three fail, the most common causes are:
- iOS: missing **Push Notifications** capability or APNs key not uploaded.
- Android: app installed before `google-services.json` was added → uninstall + reinstall.
- Both: `data` payload missing the keys above (the app's row will be empty).
