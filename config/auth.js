//config/auth.js
//expose our config directly to our app using module.exports

module.exports = {

	'facebookAuth' : {
		'clientID'		: '653564718059528', //my app ID
		'clientSecret'	: 'b0350c99c487d1861a443aea28523934', //app secret
		'callbackURL'	: 'http://localhost:8080/auth/facebook/callback'
	}

};