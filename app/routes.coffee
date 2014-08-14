module.exports = (app,passport) ->
	
#normal routes ===============================

	#show the home page
	app.get "/", (req,res) ->
		res.render "index.ejs"
		return

	#PROFILE SECTION =============================================================
	app.get "/profile", isLoggedIn, (req,res) ->
		res.render "profile.ejs",
			user : req.user
		return

	#LOGOUT ===================================
	app.get "/logout", (req,res) ->
		req.logout()
		res.redirect "/"
		return

	#About page ================
	app.get "/about", (req,res) ->
		drinks = [
			{
				name : "Bloody Mary"
				drunkness: 3
			}
				name : "Martini"
				drunkness: 5
			}
				name: "Scotch"
				drunkness:10
			}
		]
		tagline = "Paul e z3u, SADJASDJASDJASKJDKJDdksdjs"
		res.render "about.ejs",
		drinks: drinks
		tagline: tagline
		return

#AUTHENTICATE

# LOCALLY ======================
	#LOGIN
	app.get "/login", (req,res) ->
		res.render "login.ejs", 
		message: req.flash("loginMessage")
		return
	#process the login form
	app.post "/login", passport.authenticate("local-login",
		successRedirect: "/profile" #redirect to the secure profile SECTION
		failureRedirect: "/login" #redirect back to the signup page if there is an error
		failureFlash: true #allow flash messages
		)

	#SIGNUP 
	##show signup form
	app.get "/signup",(req,res) ->
		res.render "signup.ejs",
		message: req.flash('signupMessage')
		return
	#process the signup form
	app.post "/signup",passport.authenticate("local-signup",
		successRedirect: "/profile",
		failureFlash: "/signup",
		failureFlash: true
		)

	#FACEBOOK
		#send to facebook to do authentication

		app.get "/auth/facebook", passport.authenticate("facebook",
			scope: "email"
			)
		#handle the callback after fb has authenticated the user
		app.get "/auth/facebook/callback", passport.authenticate("facebook",
			successRedirect: "/profile",
			failureRedirect: "/"
			)
# =============================================================================
# AUTHORIZE (ALREADY LOGGED IN / CONNECTING OTHER SOCIAL ACCOUNT) =============
# =============================================================================

	#LOCALLY -----------------
	app.get "/connect/local", (req,res) ->
		res.render "connect-local.ejs", 
			message: req.flash("loginMessage")
			return
	app.post "/connect/local", passport.authenticate("local-signup",
		successRedirect: "/profile"
		failureRedirect: "/connect/local"
		failureFlash: true
		)

	# Facebook ----------------

		#send to facebook to do the authentication

	app.get "/connect/facebook", passport.authorize("facebook",
		scope: "email"
		)
		#handle the callback after fb has authorized the user
	app.get "/connect/facebook/callback", passport.authorize("facebook",
		successRedirect:"/profile"
		failureRedirect:"/"
		)

#UNLINK ACCOUNTS =============================================================================
#================================================================

	#local
	app.get "/unlink/local",isLoggedIn, (req,res) -> 
	user = req.user
	user.local.email = `undefined`;
	user.local.password = `undefined`;
	user.save (err) ->
		res.redirect "/profile"
		return
	return

	#facebook
	app.get "/unlink/facebook",isLoggedIn, (req,res) ->
		user = req.user
		user.facebook.token = `undefined`
		user.save (err) ->
			res.redirect "/profile"
			return
		return
return
# Route middleware to ensure user is logged index

isLoggedIn = (req,res,next) ->
	return next() if req.isAuthenticated()
	res.redirect "/"
	return

