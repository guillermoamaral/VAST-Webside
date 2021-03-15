Extension {
	#name : 'CompiledMethod'
}

{ #category : '*WebsideApp',
 #vaCategories : ['Not categorized'] }
CompiledMethod >> asWebsideJson [
	| source |
	source := self sourceString copyWithout: 10 asCharacter.
	^Dictionary new
		at: 'selector' put: selector;
		at: 'class' put: self methodClass name;
		at: 'category' put: nil;
		at: 'source' put: source;
		at: 'author' put: nil;
		at: 'timestamp' put: nil;
		at: 'project' put: nil;
		at: 'overriding' put: false;
		at: 'overriden' put: false;
		yourself
]
