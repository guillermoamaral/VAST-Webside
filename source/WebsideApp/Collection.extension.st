Extension {
	#name : 'Collection'
}

{ #category : '*WebsideApp',
 #vaCategories : ['Not categorized'] }
Collection >> groupBy: aspect [
	| answer key copy remove |
	answer := Dictionary new.
	(aspect numArgs = 0 or: [aspect isBlock and: [aspect numArgs = 1]]) ifTrue: [
		self do: [:each | 
			key := aspect value: each.
			(answer at: key ifAbsentPut: [OrderedCollection new]) add: each].
		^answer].
	copy := IdentitySet withAll: self.
	remove := IdentitySet new.
	self do: [:each | 
		copy do: [:e | 
			(aspect value: each value: e) ifTrue: [
				remove add: e.
				(answer at: each ifAbsentPut: [OrderedCollection new]) add: e]].
		copy removeAll: remove.
		remove  := IdentitySet new.].
	^answer
]
