# VAST-Webside
Implementation of [Webside](https://github.com/guillermoamaral/Webside) in VAST


## Installation


## Usage

You can start `WebsideServer` by evaluating:
```smalltalk
WebsideServer new
	baseUri: '/vast/v1';
	port: 9002;
	start
```

> Note that you can change the `baseUri` and `port` to whatever you want. This information should be promtped by Webside client once the user wants to connect to a given Smalltalk system.
