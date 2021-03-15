Class {
	#name : 'URL',
	#superclass : 'Object',
	#instVars : [
		'scheme',
		'user',
		'password',
		'host',
		'port',
		'segments',
		'query',
		'fragment'
	],
	#category : 'WebsideApp'
}

{ #category : 'Not categorized' }
URL class >> fromString: aString [
	^self new parseFrom: aString
]

{ #category : 'Not categorized' }
URL class >> new [
	^super new initialize
]

{ #category : 'Not categorized' }
URL >> , aString [
	| url segment |
	url := self copy.
	self hasPath
		ifTrue: [
			segment := self isSlash
				ifTrue: [aString]
				ifFalse: [segments last , aString].
			url segmentAt: segments size put: segment]
		ifFalse: [url addSegment: aString].
	^url
]

{ #category : 'Not categorized' }
URL >> / anURL [
	anURL isString ifTrue: [^self / anURL asURL].
	self assert: [anURL isRelative].
	self assert: [self hasQuery not].
	^self copy removeTrailingSlash
		addSegments: anURL segments;
		query: anURL query
]

{ #category : 'Not categorized' }
URL >> = anURL [
	self class == anURL class ifFalse: [^false].
	scheme = anURL scheme ifFalse: [^false].
	host = anURL host ifFalse: [^false].
	self port = anURL port ifFalse: [^false].
	fragment = anURL fragment ifFalse: [^false].
	(query difference: anURL query) isEmpty ifFalse: [^false].
	segments = anURL segments ifFalse: [^false].
	^true
]

{ #category : 'Not categorized' }
URL >> addPath: aString [
	| parts |
	parts := $/ split: aString.
	parts := parts reject: [:s | s isEmpty].
	self addSegments: parts
]

{ #category : 'Not categorized' }
URL >> addSegment: aString [
	segments add: nil.
	self segmentAt: segments size put: aString
]

{ #category : 'Not categorized' }
URL >> addSegments: aCollection [
	aCollection do: [:segment | self addSegment: segment]
]

{ #category : 'Not categorized' }
URL >> addTrailingSlash [
	self hasTrailingSlash ifFalse: [self addSegment: '/']
]

{ #category : 'Not categorized' }
URL >> asHttp [
	^self isHttp ifTrue: [self] ifFalse: [self copy beHttp]
]

{ #category : 'Not categorized' }
URL >> asJson [
	^self asString
]

{ #category : 'Not categorized' }
URL >> asURL [
	^self
]

{ #category : 'Not categorized' }
URL >> asWebSocketURL [
	^self isSecure ifTrue: [self asWss] ifFalse: [self asWs]
]

{ #category : 'Not categorized' }
URL >> asWs [
	^self isWs ifTrue: [self] ifFalse: [self copy beWs]
]

{ #category : 'Not categorized' }
URL >> asWss [
	^self isWss ifTrue: [self] ifFalse: [self copy beWss]
]

{ #category : 'Not categorized' }
URL >> baseUri [
	| base |
	self isSlash ifTrue: [^'/'].
	base := self hasPath ifTrue: [self segmentAt: 1] ifFalse: [''].
	^'/' , base
]

{ #category : 'Not categorized' }
URL >> baseUri: aString [
	self hasPath
		ifTrue: [self segmentAt: 1 put: aString]
		ifFalse: [self addSegment: aString]
]

{ #category : 'Not categorized' }
URL >> baseUrl [
	^self root / self baseUri
]

{ #category : 'Not categorized' }
URL >> beHttp [
	self scheme: 'http'
]

{ #category : 'Not categorized' }
URL >> beHttps [
	self scheme: 'https'
]

{ #category : 'Not categorized' }
URL >> beWs [
	self scheme: 'ws'
]

{ #category : 'Not categorized' }
URL >> beWss [
	self scheme: 'wss'
]

{ #category : 'Not categorized',
  #vaVisibility : 'private' }
URL >> decodeString: aString [
	^aString notNil ifTrue: [aString sstUrlDecode: true]
]

{ #category : 'Not categorized' }
URL >> defaultPort [
	(self isHttps or: [self isWss]) ifTrue: [^443].
	(self isHttp or: [self isWs]) ifTrue: [^80].
	^nil
]

{ #category : 'Not categorized' }
URL >> encodedFragment: aString [
	| encoded |
	encoded := self decodeString: aString.
	self fragment: encoded
]

{ #category : 'Not categorized' }
URL >> encodedPassword: aString [
	| decoded |
	decoded := self decodeString: aString.
	self password: decoded
]

{ #category : 'Not categorized' }
URL >> encodedPath: aString [
	| decoded |
	decoded := self decodeString: aString.
	self path: decoded
]

{ #category : 'Not categorized' }
URL >> encodedQueryAt: aString put: anotherString [
	| name value |
	name := self decodeString: aString.
	value := self decodeString: anotherString.
	self queryAt: name put: value
]

{ #category : 'Not categorized' }
URL >> encodedUser: aString [
	| decoded |
	decoded := self decodeString: aString.
	self user: decoded
]

{ #category : 'Not categorized',
  #vaVisibility : 'private' }
URL >> encodeString: aString [
	^aString notNil ifTrue: [aString sstUrlEncode]
]

{ #category : 'Not categorized' }
URL >> firstSegment [
	self isSlash ifTrue: [^nil].
	^self hasPath ifTrue: [self segmentAt: 1]
]

{ #category : 'Not categorized' }
URL >> fragment [
	^fragment
]

{ #category : 'Not categorized' }
URL >> fragment: aString [
	fragment := aString
]

{ #category : 'Not categorized' }
URL >> hasExplicitPort [
	^port notNil
]

{ #category : 'Not categorized' }
URL >> hash [
	^scheme hash * host hash * port hash * fragment hash * query hash * segments hash
]

{ #category : 'Not categorized' }
URL >> hashFragment [
	^self fragment ifNotNil: [:f | '#' , f]
]

{ #category : 'Not categorized' }
URL >> hasPath [
	^segments notEmpty
]

{ #category : 'Not categorized' }
URL >> hasQuery [
	^query notEmpty
]

{ #category : 'Not categorized' }
URL >> hasScheme [
	^scheme notNil
]

{ #category : 'Not categorized' }
URL >> hasTrailingSlash [
	^segments notEmpty and: [segments last = '/']
]

{ #category : 'Not categorized' }
URL >> host [
	^host
]

{ #category : 'Not categorized' }
URL >> host: aString [
	host := (aString notNil and: [aString beginsWith: '['])
		ifTrue: [aString allButFirst allButLast]
		ifFalse: [aString].
	host notNil ifTrue: [host := host asLowercase]
]

{ #category : 'Not categorized' }
URL >> initialize [
	super initialize.
	segments := OrderedCollection new.
	query := OrderedCollection new
]

{ #category : 'Not categorized' }
URL >> isAbsolute [
	^scheme notNil and: [host notNil]
]

{ #category : 'Not categorized' }
URL >> isEmpty [
	^host isNil and: [segments isEmpty]
]

{ #category : 'Not categorized' }
URL >> isHttp [
	^scheme = 'http'
]

{ #category : 'Not categorized' }
URL >> isHttps [
	^scheme = 'https'
]

{ #category : 'Not categorized' }
URL >> isRelative [
	^self isAbsolute not
]

{ #category : 'Not categorized' }
URL >> isSecure [
	^self isHttps or: [self isWss]
]

{ #category : 'Not categorized' }
URL >> isSlash [
	^segments size = 1 and: [segments first = '/']
]

{ #category : 'Not categorized' }
URL >> isWebSocketURL [
	^self isWss or: [self isWs]
]

{ #category : 'Not categorized' }
URL >> isWs [
	^scheme = 'ws'

]

{ #category : 'Not categorized' }
URL >> isWss [
	^scheme = 'wss'
]

{ #category : 'Not categorized',
  #vaVisibility : 'private' }
URL >> parseAuthorityFrom: aString [
	| index |
	index := aString indexOf: $@.
	index > 0
		ifTrue: 
			[self parseUserInfoFrom: (aString copyFrom: 1 to: index - 1).
			self parseHostPortFrom: (aString copyFrom: index + 1)]
		ifFalse: [self parseHostPortFrom: aString]
]

{ #category : 'Not categorized',
  #vaVisibility : 'private' }
URL >> parseFrom: aString [
	| start end index |
	start := 1.
	end := aString size.
	index := aString indexOf: $#.
	index > 0
		ifTrue: 
			[fragment := self decodeString: (aString copyFrom: index + 1 to: end).
			end := index - 1].
	index := aString indexOf: $?.
	index > 0
		ifTrue: 
			[self parseQueryFrom: (aString copyFrom: index + 1 to: end).
			end := index - 1].
	index := aString indexOfSubCollection: '://'.
	(index > 0 and: [index <= end])
		ifTrue: 
			[scheme := aString copyFrom: 1 to: index - 1.
			start := index + 3]
		ifFalse: 
			[index := aString indexOf: $:.
			(index > 0
				and: [index <= end and: [#(#mailto #telnet) includes: (aString copyFrom: 1 to: index - 1)]])
					ifTrue: 
						[scheme := aString copyFrom: 1 to: index - 1.
						start := index + 1]].
	self hasScheme
		ifTrue: 
			[index := aString indexOf: $/ startingAt: start.
			index > 0
				ifTrue: 
					[self parseAuthorityFrom: (aString copyFrom: start to: index - 1).
					start := index]
				ifFalse: [^self parseAuthorityFrom: (aString copyFrom: start to: end)]].
	self parsePathFrom: (aString copyFrom: start to: end)
]

{ #category : 'Not categorized',
  #vaVisibility : 'private' }
URL >> parseHostPortFrom: aString [
	| stream hostString portNumber |
	stream := aString readStream.
	(hostString := stream upTo: $:) isEmpty ifFalse: [self host: (self decodeString: hostString)].
	stream atEnd
		ifFalse: 
			[portNumber := Integer readFrom: stream.
			(portNumber between: 1 and: 65535) ifFalse: [self error: 'Domain must be between 1 and 65535'].
			port := portNumber]
]

{ #category : 'Not categorized',
  #vaVisibility : 'private' }
URL >> parsePathFrom: aString [
	| stream |
	stream := aString readStream.
	stream peekFor: $/.
	[stream atEnd] whileFalse: 
			[| segment |
			segment := String streamContents: 
							[:stringStream |
							[stream atEnd not and: [stream peek ~= $/]] whileTrue: [stringStream nextPut: stream next]].
			segment = '.'
				ifFalse: 
					[segment = '..'
						ifTrue: [self removeLastSegment]
						ifFalse: [self addSegment: (self decodeString: segment)]].
			((stream peekFor: $/) and: [stream atEnd]) ifTrue: [self addTrailingSlash]]
]

{ #category : 'Not categorized',
  #vaVisibility : 'private' }
URL >> parseQueryFrom: aString [
	| stream string index |
	stream := aString readStream.
	[stream atEnd] whileFalse: 
			[string := stream upTo: $&.
			index := string indexOf: $=.
			index > 0
				ifFalse: [query add: (self decodeString: string) -> nil]
				ifTrue: 
					[query add: (self decodeString: (string copyFrom: 1 to: index - 1))
								-> (self decodeString: (string copyFrom: index + 1 to: string size))]]
]

{ #category : 'Not categorized',
  #vaVisibility : 'private' }
URL >> parseUserInfoFrom: aString [
	| stream userString |
	stream := aString readStream.
	(userString := stream upTo: $:) isEmpty ifFalse: [user := self decodeString: userString].
	stream atEnd ifFalse: [password := self decodeString: stream upToEnd]
]

{ #category : 'Not categorized' }
URL >> password [
	^password
]

{ #category : 'Not categorized' }
URL >> password: aString [
	password := aString
]

{ #category : 'Not categorized' }
URL >> path [
	^String streamContents: [:strm | self printPathOn: strm]
]

{ #category : 'Not categorized' }
URL >> path: aString [
	| path |
	path := $/ split: aString.
	path := path reject: [:s | s isEmpty].
	aString last = $/ ifTrue: [path := path , #('/')].
	self segments: path
]

{ #category : 'Not categorized' }
URL >> pathAndQuery [
	^String
		streamContents: [:strm | self printPathOn: strm; printQueryOn: strm]
]

{ #category : 'Not categorized' }
URL >> port [
	^port ifNil: [self defaultPort]
]

{ #category : 'Not categorized' }
URL >> port: anInteger [
	port := anInteger
]

{ #category : 'Not categorized' }
URL >> postCopy [
	super postCopy.
	segments := segments copy.
	query := query copy
]

{ #category : 'Not categorized' }
URL >> printAuthorityOn: aStream [
	(user notNil and: [password notNil]) ifTrue: [
		aStream
			nextPutAll: user;
			nextPut: $:;
			nextPutAll: password;
			nextPut: $@]
]

{ #category : 'Not categorized' }
URL >> printFragmentOn: aStream [
	fragment notNil ifTrue: [aStream nextPut: $#; nextPutAll: fragment]
]

{ #category : 'Not categorized' }
URL >> printHostOn: aStream [
	host notNil ifTrue: [aStream nextPutAll: host]
]

{ #category : 'Not categorized' }
URL >> printOn: aStream [
	self
		printSchemeOn: aStream;
		printAuthorityOn: aStream;
		printHostOn: aStream;
		printPortOn: aStream;
		printPathOn: aStream;
		printQueryOn: aStream;
		printFragmentOn: aStream
]

{ #category : 'Not categorized' }
URL >> printPathOn: aStream [
	self printSegments: segments on: aStream
]

{ #category : 'Not categorized' }
URL >> printPortOn: aStream [
	(host notNil and: [port notNil])
		ifTrue: [aStream nextPut: $:; nextPutAll: port printString]
]

{ #category : 'Not categorized' }
URL >> printQueryOn: aStream [
	self hasQuery ifFalse: [^self].
	aStream nextPut: $?.
	query isString ifTrue: [^aStream nextPutAll: query].
	self queryOptions
		do: [:option | self printQueryOption: option on: aStream]
		separatedBy: [aStream nextPut: $&]
]

{ #category : 'Not categorized' }
URL >> printQueryOption: option on: aStream [
	| name value |
	name := self encodeString: option key asString.
	value := self encodeString: option value asString.
	aStream
		nextPutAll: name;
		nextPut: $=;
		nextPutAll: value
]

{ #category : 'Not categorized' }
URL >> printSchemeOn: aStream [
	(host notNil and: [scheme notNil])
		ifTrue: [aStream nextPutAll: scheme; nextPutAll: '://']
]

{ #category : 'Not categorized' }
URL >> printSegments: aCollection on: aStream [
	aCollection
		do: [:segment | segment ~= '/'
			ifTrue: [aStream nextPut: $/; nextPutAll: segment]].
	(aCollection notEmpty and: [aCollection last = '/'])
		ifTrue: [aStream nextPut: $/]
]

{ #category : 'Not categorized' }
URL >> printWithoutPort [
	^String streamContents: [:strm | 
		self
			printSchemeOn: strm;
			printAuthorityOn: strm;
			printHostOn: strm;
			printPathOn: strm;
			printQueryOn: strm;
			printFragmentOn: strm]
]

{ #category : 'Not categorized' }
URL >> protocol [
	^scheme
]

{ #category : 'Not categorized' }
URL >> protocol: aString [
	self scheme: aString
]

{ #category : 'Not categorized',
  #vaVisibility : 'private' }
URL >> query [
	^query
]

{ #category : 'Not categorized' }
URL >> query: anOrderedCollection [
	anOrderedCollection isNil ifTrue: [^self].
	query := anOrderedCollection
]

{ #category : 'Not categorized' }
URL >> queryAt: aString [
	| option |
	option := query detect: [:o | o key = aString] ifNone: [].
	^option notNil ifTrue: [option value]
]

{ #category : 'Not categorized' }
URL >> queryAt: name put: value [
	query add: name trimBlanks -> value trimBlanks
]

{ #category : 'Not categorized' }
URL >> queryOptions [
	^query
]

{ #category : 'Not categorized' }
URL >> queryString [
	query isString ifTrue: [^query].
	^String streamContents: [:strm | self printQueryOn: strm]
]

{ #category : 'Not categorized' }
URL >> relativeUri [
	segments size < 2 ifTrue: [^'/'].
	^String
		streamContents: [:strm | self printSegments: segments allButFirst on: strm]
]

{ #category : 'Not categorized' }
URL >> removeLastSegment [
	self hasPath ifTrue: [segments removeLast]
]

{ #category : 'Not categorized' }
URL >> removeSegment: aString [
	segments remove: aString ifAbsent: []
]

{ #category : 'Not categorized' }
URL >> removeSubpath: aString [
	| subpath index |
	subpath := $/ split: aString.
	subpath := subpath reject: [:s | s isEmpty].
	index := segments indexOfSubCollection: subpath.
	index = 0 ifTrue: [^self].
	segments := (segments copyFrom: 1 to: index - 1)
		, (segments copyFrom: index + subpath size)
]

{ #category : 'Not categorized' }
URL >> removeTrailingSlash [
	self hasTrailingSlash ifTrue: [segments removeLast]
]

{ #category : 'Not categorized' }
URL >> replaceQueryAt: name with: value [
	| option |
	option := query detect: [:o | o key = name] ifNone: nil.
	^option notNil ifTrue: [option value: value]
]

{ #category : 'Not categorized' }
URL >> root [
	^self class new
		scheme: scheme;
		host: host;
		port: port
]

{ #category : 'Not categorized' }
URL >> scheme [
	^scheme
]

{ #category : 'Not categorized' }
URL >> scheme: aString [
	scheme := aString notNil ifTrue: [aString asLowercase]
]

{ #category : 'Not categorized' }
URL >> segmentAt: anInteger [
	^segments at: anInteger
]

{ #category : 'Not categorized' }
URL >> segmentAt: anInteger put: aString [
	| segment |
	segment := (aString first = $/ and: [aString ~= '/'])
		ifTrue: [aString allButFirst]
		ifFalse: [aString].
	segments at: anInteger put: segment
]

{ #category : 'Not categorized' }
URL >> segments [
	^segments
]

{ #category : 'Not categorized' }
URL >> segments: aCollection [
	segments := aCollection asOrderedCollection
]

{ #category : 'Not categorized' }
URL >> user [
	^user
]

{ #category : 'Not categorized' }
URL >> user: aString [
	user := aString
]
