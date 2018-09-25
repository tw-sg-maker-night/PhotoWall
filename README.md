# AR Photo Wall

# Pre-Requisites
- XCode 10
- Ruby 2.4.0
- A device running iOS 12

# Development
- `bundle`
- `pod install`
- `fastlane match development`
- `cp PhotoWall/Secrets_template.plist PhotoWall/Secrets.plist`
- Add the AWSSecretKey and AWSAccessKey values to `Secrets.plist`

# Add a new device
- Download the latest certs/profiles: `fastlane match development`
- Add the new device name and identifier here: `./fastlane/Fastlane`
  - Replace `<device name>` with the name of your device
  - Replace `<device identifier>` with the identifier of your device
- Add the new device: `bundle exec fastlane add_device`
- Upload the new certs/profiles: `bundle exec fastlane match development --force_for_new_devices`
- Revert your changes to `./fastlane/Fastlane`

# Icons
Most icons from https://icons8.com/
