alias i := install
alias o := open

install:
    pod deintegrate
    rm -rf Quickstart.xcworkspace
    pod install

open:
	open Quickstart.xcworkspace
