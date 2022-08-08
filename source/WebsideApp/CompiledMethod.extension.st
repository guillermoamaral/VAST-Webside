Extension {
	#name : 'CompiledMethod'
}

{ #category : 'Not categorized' }
CompiledMethod >> asWebsideJson [
	| source categories category |
	source := self sourceString copyWithout: 10 asCharacter.
	categories := self methodClass categoriesFor: self selector.
	category := categories notEmpty ifTrue: [categories first].
	^super asWebsideJson
		at: 'selector' put: selector;
		at: 'methodClass' put: self methodClass name;
		at: 'category' put: category printString;
		at: 'source' put: source;
		at: 'author' put: nil;
		at: 'timestamp' put: nil;
		at: 'project' put: nil;
		at: 'overriding' put: false;
		at: 'overriden' put: false;
		yourself
]
