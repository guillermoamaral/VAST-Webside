Extension {
	#name : 'String'
}

{ #category : 'Not categorized' }
String >> asURL [
	^URL fromString: self
]
