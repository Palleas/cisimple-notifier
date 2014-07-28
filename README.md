# shipio notifier

(https://ship.io/assets/dev_center/third_party/screenshot1.png)

This application connects to ship.io and sends you a notification when something happens on one of your jobs :
  
  * When a job was queued
  * When a job started
  * When a job succeeded / failed

Download it directly from [shipio](https://ship.io/help/#third_party).

## Installation

(I'm assuming [cocoapods](http://cocoapods.org/) is installed on your machine)

    $ git clone git@github.com:Palleas/shipio-notifier.git
    $ cd shipio-notifier
    $ pod install
    $ open ShipIO-notifier.xcworkspace
  
## Many thanks to...

  * Sam Vermette for [SVHTTPRequest](https://github.com/samvermette/SVHTTPRequest)
  * Sam Soffes for [Bully](https://github.com/soffes/bully) and [SSkeychain](https://github.com/soffes/sskeychain)
  * The guys at [shipio](https://ship.io) for their life-saving service

## Contribution

I'm pretty sure there is room for improvement, feel free to report an issue or send me a pull-request! 
