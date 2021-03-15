Class {
	#name : 'StarToken',
	#superclass : 'Object',
	#classInstVars : [
		'current'
	],
	#category : 'WebsideApp'
}

{ #category : 'Not categorized' }
StarToken class >> current [
	current isNil ifTrue: [self initializeCurrent].
	^current
]

{ #category : 'Not categorized' }
StarToken class >> initialize [
	"
	StarToken initialize
	"
	super initialize.
	self initializeCurrent
]

{ #category : 'Not categorized' }
StarToken class >> initializeCurrent [
	current := self new
]

{ #category : 'Not categorized' }
StarToken >> matchFirstAfterStartOn: aMatchAlgorithm [
	aMatchAlgorithm matchFirstStar
]

{ #category : 'Not categorized' }
StarToken >> matchFirstOn: aMatchAlgorithm [
	aMatchAlgorithm matchFirstStar
]

{ #category : 'Not categorized' }
StarToken >> matchLastOn: aMatchAlgorithm [
	"
	do nothing
	"
	
]

{ #category : 'Not categorized' }
StarToken >> printOn: aStream [
	aStream nextPut: $*
]
