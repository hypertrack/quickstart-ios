alias ogp := open-github-prs
alias us := update-sdk

SDK_NAME := "HyperTrack SDK iOS"
REPOSITORY_NAME := "quickstart-ios"

open-github-prs:
    open "https://github.com/hypertrack/{{REPOSITORY_NAME}}/pulls"

update-sdk ios_version:
    git checkout -b update-sdk-{{ios_version}}
    just _update-sdk-ios-version-file {{ios_version}}
    git add .
    git commit -m "Update {{SDK_NAME}} to {{ios_version}}"
    just open-github-prs

_update-sdk-ios-version-file ios_version:
    ./scripts/update_file.sh Quickstart.xcodeproj/project.pbxproj "version = .*;" "version = {{ios_version}};"
