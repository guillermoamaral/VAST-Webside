Class {
	#name : 'WebsideTest',
	#superclass : 'TestCase',
	#instVars : [
		'client',
		'server',
		'uri'
	],
	#category : 'WebsideTestsApp'
}

{ #category : 'running',
  #vaVisibility : 'private' }
WebsideTest >> get: relativeUri [

	| responseMsg data |

	client startUp isSstError ifTrue: [self error: 'Error'].
	[responseMsg := client get: uri , '/' , relativeUri] ensure: [client shutDown].
	(responseMsg isSstError or: [responseMsg isNil]) ifTrue: [self error: 'Error'].
	data := responseMsg basicContents.
	^ NeoJSONObject fromString: data
]

{ #category : 'running',
  #vaVisibility : 'private' }
WebsideTest >> post: relativeUri [

	^self post: relativeUri with: ''
]

{ #category : 'running',
  #vaVisibility : 'private' }
WebsideTest >> post: relativeUri with: body [

	| responseMsg data |

	client startUp isSstError ifTrue: [self error: 'Error'].
	[responseMsg := client post: body asString typed: 'application/json' at: uri , '/' , relativeUri]
		ensure: [client shutDown].
	(responseMsg isSstError or: [responseMsg isNil]) ifTrue: [self error: 'Error'].
	data := responseMsg basicContents.
	^NeoJSONObject fromString: data
]

{ #category : 'running',
  #vaVisibility : 'private' }
WebsideTest >> setUp [

	| host port baseUri |

	super setUp.
	host := 'localhost'.
	port := 9876.
	baseUri := '/WebsideTests'.
	uri := 'http://', host, ':', port asString, baseUri.		
	client := SstHttpClient forTransportScheme: 'httpl'.
	WebsideServer allInstancesDo: [:each | each stop].
	server :=
		WebsideServer new
			port: port;
			baseUri: baseUri;
			start.
	


]

{ #category : 'running',
  #vaVisibility : 'private' }
WebsideTest >> tearDown [
	super tearDown.
	server stop.
	client shutDown.
]

{ #category : 'code endpoints' }
WebsideTest >> testAccessors [
	| accessors |
	accessors := self get: 'methods?class=Fraction&referencing=numerator'.
	self
		assert: accessors notEmpty;
		assert: (accessors conform: [:m | m source includesSubstring: 'numerator']).
	accessors := self get: 'methods?class=Fraction&assigning=numerator'.
	self
		assert: accessors notEmpty;
		assert: (accessors conform: [:m | m source includesSubstring: 'numerator :='])
]

{ #category : 'code endpoints' }
WebsideTest >> testCategories [
	| categories |
	categories := self get: 'classes/Point/categories'.
	self
		assert: categories notEmpty;
		assert: (categories conform: #isString);
		assert: (categories includes: 'arithmetic')
]

{ #category : 'code endpoints' }
WebsideTest >> testClassDefinition [
	| definition |
	definition := self get: 'classes/Point'.
	self
		assert: definition name = 'Point';
		assert: (definition definition includesSubstring: 'x');
		assert: (definition definition includesSubstring: 'y')
]

{ #category : 'code endpoints' }
WebsideTest >> testClasses [
	| classes names tree root integer |
	classes := self get: 'classes?root=Magnitude'.
	self
		assert: (classes anySatisfy: [:c | c name = 'Date']);
		assert: (classes
			anySatisfy: [:c | c name = 'Fraction'
				and: [c definition includesSubstring: 'denominator']]).
	names := self get: 'classes?root=Magnitude&names=true'.
	self
		assert: names notEmpty;
		assert: (names conform: #isString).
	tree := self get: 'classes?root=Number&tree=true'.
	self
		assert: tree isCollection;
		assert: tree size = 1.
	root := tree anyone.
	self
		assert: root name = 'Number';
		assert: (root subclasses anySatisfy: [:c | c name = 'Integer']).
	integer := root subclasses detect: [:c | c name = 'Integer'].
	self assert: (integer subclasses anySatisfy: [:c | c name = 'SmallInteger'])
]

{ #category : 'code endpoints' }
WebsideTest >> testClassVariables [
	| variables |
	variables := self get: 'classes/Float/class-variables'.
	self assert: (variables anySatisfy: [:v | v name = 'Infinity'])
]

{ #category : 'code endpoints' }
WebsideTest >> testDialect [
	| dialect |
	dialect := self get: 'dialect'.
	self assert: dialect = 'Bee'
]

{ #category : 'code endpoints' }
WebsideTest >> testImplementors [
	| implementors local |
	implementors := self get: 'methods?selector=reciprocal'.
	self
		assert: implementors notEmpty;
		assert: (implementors conform: [:m | m selector = 'reciprocal']);
		assert: (implementors anySatisfy: [:m | (m at: 'class') = 'Fraction']).
	local := self get: 'methods?selector=reciprocal&class=Fraction'.
	self
		assert: local notEmpty;
		assert: (local conform: [:m | m selector = 'reciprocal']);
		assert: (local conform: [:m | (m at: 'class') = 'Fraction'])
]

{ #category : 'code endpoints' }
WebsideTest >> testInstanceVariables [
	| variables |
	variables := self get: 'classes/Fraction/instance-variables'.
	self
		assert: (variables anySatisfy: [:v | v name = 'numerator']);
		assert: (variables anySatisfy: [:v | v name = 'denominator'])
]

{ #category : 'code endpoints' }
WebsideTest >> testMethod [
	| method |
	method := self get: 'classes/Point/methods/x'.
	self
		assert: method selector = 'x';
		assert: ((method source includesSubstring: '^x')
			or: [method source includesSubstring: '^ x'])
]

{ #category : 'code endpoints' }
WebsideTest >> testMethods [
	| methods |
	methods := self get: 'classes/Point/methods'.
	self
		assert: methods notEmpty;
		assert: (methods conform: [:m | (m at: 'class') = 'Point'])
]

{ #category : 'code endpoints' }
WebsideTest >> testReferences [
	| references |
	references := self get: 'methods?referencing=Fraction'.
	self
		assert: references notEmpty;
		assert: (references conform: [:m | m source includesSubstring: 'Fraction'])
]

{ #category : 'code endpoints' }
WebsideTest >> testSenders [
	| senders local |
	senders := self get: 'methods?sending=reciprocal'.
	self
		assert: senders notEmpty;
		assert: (senders conform: [:m | m source includesSubstring: 'reciprocal']);
		assert: (senders anySatisfy: [:m | (m at: 'class') = 'Fraction']).
	local := self get: 'methods?sending=reciprocal&class=Fraction'.
	self
		assert: local notEmpty;
		assert: (local conform: [:m | m source includesSubstring: ' reciprocal']);
		assert: (local conform: [:m | (m at: 'class') = 'Fraction'])
]

{ #category : 'code endpoints' }
WebsideTest >> testSubclasses [
	| subclasses |
	subclasses := self get: 'classes/Magnitude/subclasses'.
	self
		assert: (subclasses anySatisfy: [:c | c name = 'Time']);
		assert: (subclasses anySatisfy: [:c | c name = 'Number'])
]

{ #category : 'code endpoints' }
WebsideTest >> testVariables [
	| variables |
	variables := self get: 'classes/Float/variables'.
	self assert: (variables anySatisfy: [:v | v name = 'Infinity']).
	variables := self get: 'classes/Fraction/variables'.
	self
		assert: (variables anySatisfy: [:v | v name = 'numerator']);
		assert: (variables anySatisfy: [:v | v name = 'denominator'])
]
