Extension {
	#name : 'String'
}

{ #category : '*WebsideApp',
 #vaCategories : ['Not categorized'] }
String >> asURL [
	^URL fromString: self
]
