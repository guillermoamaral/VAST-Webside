Class {
	#name : 'HttpRequestRouter',
	#superclass : 'Object',
	#instVars : [
		'routes',
		'receiver'
	],
	#category : 'WebsideApp'
}

{ #category : 'Not categorized' }
HttpRequestRouter class >> new [
	^super new initialize
]

{ #category : 'Not categorized',
  #vaVisibility : 'private' }
HttpRequestRouter >> actionFor: route verb: verb [
	^(routes at: verb) at: route
]

{ #category : 'Not categorized' }
HttpRequestRouter >> initialize [
	super initialize.
	routes := Dictionary new.
	self supportedVerbs
		do: [:verb | routes at: verb put: Dictionary new]
]

{ #category : 'Not categorized',
  #vaVisibility : 'private' }
HttpRequestRouter >> performAction: action for: request [
	| target selector arguments |
	(action isKindOf: DirectedMessage) ifTrue: [
		target := action receiver value.
		(target respondsTo: #request:) ifTrue: [target request: request].
		selector := action selector.
		arguments := request header at: #arguments ifAbsent: [Dictionary new].
		^target notNil
			ifTrue: [
				(selector numArgs = arguments size and: [target respondsTo: selector])
					ifTrue: [target perform: selector withArguments: arguments asArray]
					ifFalse: [target perform: selector]]
			ifFalse: [action value]].
	^action value: request
]

{ #category : 'Not categorized' }
HttpRequestRouter >> receiver: evaluable [
	receiver := evaluable
]

{ #category : 'Not categorized' }
HttpRequestRouter >> route: request [
	| route url arguments action |
	route := self routeFor: request.
	route isNil ifTrue: [^SstCommunicationMessage notFound].
	url := request header url asURL.
	arguments := route argumentsFrom: url.
	request header at: #arguments put: arguments.
	action := self actionFor: route verb: request header command.
	^self performAction: action for: request

]

{ #category : 'Not categorized',
  #vaVisibility : 'private' }
HttpRequestRouter >> route: uri verb: method action: selector [
	self route: uri verb: method to: selector
]

{ #category : 'Not categorized',
  #vaVisibility : 'private' }
HttpRequestRouter >> route: uri verb: method to: evaluable [
	| template action |
	template := URLTemplate on: uri.
	action := evaluable isSymbol
		ifTrue: [DirectedMessage new receiver: receiver; selector: evaluable]
		ifFalse: [evaluable].
	(routes at: method) at: template put: action 
]

{ #category : 'Not categorized',
  #vaVisibility : 'private' }
HttpRequestRouter >> routeAllTo: uri to: action [
	self supportedVerbs do: [:verb | self route: uri verb: verb action: action]
]

{ #category : 'Not categorized',
  #vaVisibility : 'private' }
HttpRequestRouter >> routeDELETE: uri to: action [
	self route: uri verb: 'DELETE' action: action
]

{ #category : 'Not categorized',
  #vaVisibility : 'private' }
HttpRequestRouter >> routeFor: request [
	| candidates url |
	candidates := routes at: request header command ifAbsent: [^nil].
	url := request header url asString asURL.
	(url hasTrailingSlash and: [url segments size > 2])
		ifTrue: [url removeTrailingSlash]
		ifFalse: [url path = url baseUri ifTrue: [url addTrailingSlash]].
	^candidates keys detect: [:template | template matches: url] ifNone: []
]

{ #category : 'Not categorized',
  #vaVisibility : 'private' }
HttpRequestRouter >> routeGET: uri to: action [
	self route: uri verb: 'GET' action: action
]

{ #category : 'Not categorized',
  #vaVisibility : 'private' }
HttpRequestRouter >> routeHEAD: uri to: action [
	self route: uri verb: 'HEAD' action: action
]

{ #category : 'Not categorized',
  #vaVisibility : 'private' }
HttpRequestRouter >> routePOST: uri to: action [
	self route: uri verb: 'POST' action: action
]

{ #category : 'Not categorized',
  #vaVisibility : 'private' }
HttpRequestRouter >> routePUT: uri to: action [
	self route: uri verb: 'PUT' action: action
]

{ #category : 'Not categorized' }
HttpRequestRouter >> supportedVerbs [
	^#('GET' 'POST' 'DELETE' 'HEAD' 'PUT')
]
