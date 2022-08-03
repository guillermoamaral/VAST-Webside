"
self startServer

self stopServer

"
Class {
	#name : 'WebsideAPI',
	#superclass : 'Object',
	#instVars : [
		'server',
		'request'
	],
	#category : 'WebsideApp'
}

{ #category : 'code endpoints' }
WebsideAPI >> categories [
	| class |
	class := self requestedClass.
	class ifNil: [^self notFound].
	^(class methodCategories collect: [:c | c]) asArray

]

{ #category : 'code endpoints' }
WebsideAPI >> classDefinition [
	| class |
	class := self requestedClass.
	class ifNil: [^self notFound].
	^class asWebsideJson
]

{ #category : 'code endpoints' }
WebsideAPI >> classes [
	| root tree classes names depth json |
	root := self queryAt: 'root'.
	root := root notNil
		ifTrue: [self classNamed: root]
		ifFalse: [self defaultRootClass].
	root ifNil: [^self notFound].
	tree := self queryAt: 'tree'.
	tree = 'true' ifTrue: [
		depth := self queryAt: 'depth'.
		depth := depth notNil ifTrue: [depth := depth asNumber].
		json := self classTreeFrom: root depth: depth.
		^Array with: json].
	classes := root withAllSubclasses reject: [:c | c isMeta ].
	names := self queryAt: 'names'.
	names = 'true' ifTrue: [^(classes collect: [:c | c name]) sort].
	^classes collect: [:c | c asWebsideJson]
]

{ #category : 'services',
  #vaVisibility : 'private' }
WebsideAPI >> classNamed: aString [
	| name suffix metaclass class |
	name := aString.
	suffix := ' class'.
	metaclass := (name last: (suffix size min: aString size)) = suffix.
	metaclass ifTrue: [name := name allButLast: suffix size].
	class := Smalltalk at: name asSymbol ifAbsent: [^nil].
	^metaclass ifTrue: [class class] ifFalse: [class]
]

{ #category : 'services',
  #vaVisibility : 'private' }
WebsideAPI >> classTreeFrom: aClass depth: anInteger [
	| json subclasses depth names |
	names := self queryAt: 'names'.
	json := names = 'true'
		ifTrue: [
			Dictionary new
				at: 'name' put: aClass name;
				at: 'superclass'
				put: (aClass superclass ifNotNil: [:c | c name]);
				yourself]
		ifFalse: [aClass asWebsideJson].
	(anInteger notNil and: [anInteger = 0]) ifTrue: [^json].
	depth := anInteger notNil ifTrue: [anInteger - 1].
	subclasses := (aClass subclasses asSortedCollection: [:a :b | a name <= b name])
		collect: [:c | self classTreeFrom: c depth: depth].
	json at: 'subclasses' put: subclasses asArray.
	^json
]

{ #category : 'code endpoints' }
WebsideAPI >> classVariables [
	| class variables |
	class := self requestedClass.
	class ifNil: [^self notFound].
	variables := OrderedCollection new.
	class withAllSuperclasses do: [:c | 
		c classVarNames asArray sort do: [:v | | d | 
			d := Dictionary new
				at: 'name' put: v;
				at: 'class' put: c name , ' class';
				yourself.
			variables add: d]].
	^variables asArray
]

{ #category : 'services',
  #vaVisibility : 'private' }
WebsideAPI >> defaultRootClass [
	^Object
]

{ #category : 'code endpoints' }
WebsideAPI >> dialect [
	^'VAST'
]

{ #category : 'services',
  #vaVisibility : 'private' }
WebsideAPI >> filterByCategory: aCollection [
	| category |
	category := self queriedCategory.
	^(category notNil and: [category notEmpty])
		ifTrue: [aCollection select: [:m | m category = category]]
		ifFalse: [aCollection]
]

{ #category : 'services',
  #vaVisibility : 'private' }
WebsideAPI >> filterByVariable: aCollection [
	| grouped filtered variable filter |
	grouped := aCollection groupBy: [:m | m methodClass].
	filtered := OrderedCollection new.
	variable := self queriedReferencing.
	filter := false.
	variable ifNotNil: [
		filter := true.
		grouped keysAndValuesDo: [:class :methods | | slot var |
			slot := class allInstVarNames indexOf: variable ifAbsent: nil.
			slot notNil
				ifTrue: [methods
					select: [:m | m referencesInstanceVariable: slot]
					in: filtered].
			var := class classVariableAssociationAt: variable.
			var notNil
				ifTrue: [methods
					select: [:m | m referencesAssociation: slot]
					in: filtered]]].
	variable := self queriedUsing.
	variable ifNotNil: [
		filter := true.
		grouped keysAndValuesDo: [:class :methods | | slot var |
			slot := class allInstVarNames indexOf: variable ifAbsent: nil.
			slot notNil
				ifTrue: [methods
					select: [:m | m usesInstanceVariable: slot]
					in: filtered].
			var := class classVariableAssociationAt: variable.
			var notNil
				ifTrue: [methods select: [:m | m usesAssociation: slot] in: filtered]]].
	variable := self queriedAssigning.
	variable ifNotNil: [
		filter := true.
		grouped keysAndValuesDo: [:class :methods | | slot var |
			slot := class allInstVarNames indexOf: variable ifAbsent: nil.
			slot notNil
				ifTrue: [methods
					select: [:m | m assignsInstanceVariable: slot]
					in: filtered].
			var := class classVariableAssociationAt: variable.
			var notNil
				ifTrue: [methods select: [:m | m assignsAssociation: slot] in: filtered]]].
	^filter ifTrue: [filtered] ifFalse: [aCollection]
]

{ #category : 'services',
  #vaVisibility : 'private' }
WebsideAPI >> implementorsOf: aSymbol [
	| scope |
	scope := self queriedScope ifNil: [Object].
	^ scope allMethodsNamed:  aSymbol 
]

{ #category : 'code endpoints' }
WebsideAPI >> instanceVariables [
	| class variables |
	class := self requestedClass.
	class isNil ifTrue: [^self notFound].
	variables := OrderedCollection new.
	class withAllSuperclasses
		do: [:c | 
			c instVarNames do: [:v | | d | 
				d := Dictionary new
					at: 'name' put: v;
					at: 'class' put: c name;
					yourself.
				variables add: d]].
	^variables asArray
]

{ #category : 'code endpoints' }
WebsideAPI >> method [
	| class selector |
	class := self requestedClass.
	class ifNil: [^self notFound].
	selector := self requestedSelector.
	selector ifNil: [^self notFound].
	(class includesSelector: selector) ifFalse: [^self notFound].
	^(class >> selector) asWebsideJson
]

{ #category : 'code endpoints' }
WebsideAPI >> methods [
	| selector methods senders global references class |
	selector := self queriedSelector.
	selector notNil ifTrue: [methods := self implementorsOf: selector].
	selector := self queriedSending.
	selector notNil ifTrue: [
		senders := self sendersOf: selector.
		methods := methods
			ifNil: [senders]
			ifNotNil: [methods intersection: senders]].
	global := self queriedReferencingClass.
	global notNil ifTrue: [
		references := self referencesTo: global.
		methods := methods
			ifNil: [references]
			ifNotNil: [methods intersection: references]].
	class := self requestedClass ifNil: [self queriedClass].
	(class notNil and: [methods notNil])
		ifTrue: [methods := methods select: [:m | m methodClass == class]].
	methods
		ifNil: [methods := OrderedCollection new.
			(class ifNil: [self defaultRootClass]) methodsDo: [:m | methods add: m]].
	methods := self filterByCategory: methods.
	methods := self filterByVariable: methods.
	^(methods collect: [:m | m asWebsideJson]) asArray
]

{ #category : 'services',
  #vaVisibility : 'private' }
WebsideAPI >> notFound [
	^#HttpServerResponse notFound
]

{ #category : 'code endpoints' }
WebsideAPI >> package [
	| package |
	package := self requestedPackage.
	package ifNil: [^self notFound].
	^package asWebsideJson
]

{ #category : 'code endpoints' }
WebsideAPI >> packages [
	^#()
]

{ #category : 'services',
  #vaVisibility : 'private' }
WebsideAPI >> queriedAssigning [
	^self queryAt: 'assigning'
]

{ #category : 'services',
  #vaVisibility : 'private' }
WebsideAPI >> queriedCategory [
	^self queryAt: 'category' ifPresent: [:c | c asSymbol]
]

{ #category : 'services',
  #vaVisibility : 'private' }
WebsideAPI >> queriedClass [
	^self queryAt: 'class' ifPresent: [:n | self classNamed: n]
]

{ #category : 'services',
  #vaVisibility : 'private' }
WebsideAPI >> queriedReferencing [
	^self queriedReferencingClass isNil ifTrue: [self queryAt: 'referencing']
]

{ #category : 'services',
  #vaVisibility : 'private' }
WebsideAPI >> queriedReferencingClass [
	^self queryAt: 'referencingClass' ifPresent: [:n | self classNamed: n ]
]

{ #category : 'services',
  #vaVisibility : 'private' }
WebsideAPI >> queriedScope [
	^self queryAt: 'scope' ifPresent: [:s | self classNamed: s ]
]

{ #category : 'services',
  #vaVisibility : 'private' }
WebsideAPI >> queriedSelector [
	^self queryAt: 'selector' ifPresent: [:s | s asSymbol]
]

{ #category : 'services',
  #vaVisibility : 'private' }
WebsideAPI >> queriedSending [
	^self queryAt: 'sending' ifPresent: [:s | s asSymbol]
]

{ #category : 'services',
  #vaVisibility : 'private' }
WebsideAPI >> queriedUsing [
	^self queryAt: 'using'
]

{ #category : 'services',
  #vaVisibility : 'private' }
WebsideAPI >> queryAt: aString [
	^ self queryAt: aString ifAbsent: nil
]

{ #category : 'services',
  #vaVisibility : 'private' }
WebsideAPI >> queryAt: aString ifAbsent: aBlock [
	^ self queryAt: aString ifPresent: nil ifAbsent: aBlock
]

{ #category : 'services',
  #vaVisibility : 'private' }
WebsideAPI >> queryAt: aString ifPresent: aBlock [
	^ self queryAt: aString ifPresent: aBlock ifAbsent: nil
]

{ #category : 'services',
  #vaVisibility : 'private' }
WebsideAPI >> queryAt: aString ifPresent: aBlock ifAbsent: anotherBlock [
	| value |
	value := request at: aString ifAbsent: nil.
	value ifNil: [ ^ anotherBlock value ].
	^ aBlock notNil
		ifTrue: [ aBlock value: value ]
		ifFalse: [ value ]
]

{ #category : 'services',
  #vaVisibility : 'private' }
WebsideAPI >> referencesTo: aClass [
	^ Object allMethodsReferencingLiteral: aClass
]

{ #category : 'accessing' }
WebsideAPI >> request: anHttpRequest [
	request := anHttpRequest
]

{ #category : 'services',
  #vaVisibility : 'private' }
WebsideAPI >> requestedClass [
	| name |
	name := self urlAt: 'name'.
	^name ifNotNil: [self classNamed: name]
]

{ #category : 'services',
  #vaVisibility : 'private' }
WebsideAPI >> requestedPackage [
	| name |
	name := self urlAt: 'name'.
	^name ifNotNil: [#PackageManager current packageNamed: name ifNone: []]
]

{ #category : 'services',
  #vaVisibility : 'private' }
WebsideAPI >> requestedSelector [
	| selector |
	selector := self urlAt: 'selector'.
	^selector ifNotNil: [selector asSymbol]
]

{ #category : 'services',
  #vaVisibility : 'private' }
WebsideAPI >> sendersOf: aSymbol [
	| scope |
	scope := self queriedScope ifNil: [Object].
	^scope allMethodsSending: aSymbol
]

{ #category : 'accessing' }
WebsideAPI >> server: aWebsideServer [
	server := aWebsideServer
]

{ #category : 'code endpoints' }
WebsideAPI >> subclasses [
	| class |
	class := self requestedClass.
	class ifNil: [^self notFound].
	^(class subclasses collect: [:c | c asWebsideJson]) asArray
]

{ #category : 'services',
  #vaVisibility : 'private' }
WebsideAPI >> urlAt: aString [
	| arguments |
	arguments := request header at: #arguments ifAbsent: [^nil].
	^arguments at: aString ifAbsent: []
]

{ #category : 'code endpoints' }
WebsideAPI >> variables [
	| class |
	class := self requestedClass.
	class ifNil: [^self notFound].
	^self instanceVariables , self classVariables
]
