isLoggedIn = (req, res, next) ->
	return next()  if req.isAuthenticated()
	res.redirect "/"
	return

module.exports = (app, passport) ->
  
	# normal routes ===============================================================
  
	# show the home page (will also have our login links)
	app.get "/", (req, res) ->
		res.render "index.ejs"
	return

	app.get "/profile", isLoggedIn, (req, res) ->
		res.render "profile.ejs",
		user: req.user
	return

# LOGOUT ==============================
	app.get "/logout", (req, res) ->
		req.logout()
		res.redirect "/"
	return
 
	app.get "/login", (req, res) ->
		res.render "login.ejs",
		message: req.flash("loginMessage")
	return

  
	# process the login form
	app.post "/login", passport.authenticate("local-login",
	successRedirect: "/profile" # redirect to the secure profile section
	failureRedirect: "/login" # redirect back to the signup page if there is an error
	failureFlash: true	#allow flash messages
	)
  
	# SIGNUP =================================
	# show the signup form
	app.get "/signup", (req, res) ->
	res.render "signup.ejs",
	message: req.flash("signupMessage")
	return

  
	# process the signup form
	app.post "/signup", passport.authenticate("local-signup",
	successRedirect: "/profile" # redirect to the secure profile section
	failureRedirect: "/signup" # redirect back to the signup page if there is an error
	failureFlash: true # allow flash messages
	)
  
	 # facebook -------------------------------
  
	# send to facebook to do the authentication
	app.get "/auth/facebook", passport.authenticate("facebook",
	scope: "email"
	)
  
  # handle the callback after facebook has authenticated the user
	app.get "/auth/facebook/callback", passport.authenticate("facebook",
	successRedirect: "/profile"
	failureRedirect: "/"
	)
  
	# =============================================================================
	# AUTHORIZE (ALREADY LOGGED IN / CONNECTING OTHER SOCIAL ACCOUNT) =============
	# =============================================================================
  
	# locally --------------------------------
	app.get "/connect/local", (req, res) ->
	res.render "connect-local.ejs",
	message: req.flash("loginMessage")
	return

	app.post "/connect/local", passport.authenticate("local-signup",
	successRedirect: "/profile" # redirect to the secure profile section
	failureRedirect: "/connect/local" # redirect back to the signup page if there is an error
	failureFlash: true # allow flash messages
	)	
  
	# facebook -------------------------------
  
	# send to facebook to do the authentication
	app.get "/connect/facebook", passport.authorize("facebook",
	scope: "email"
	)
  
	# handle the callback after facebook has authorized the user
	app.get "/connect/facebook/callback", passport.authorize("facebook",
	successRedirect: "/profile"
	failureRedirect: "/"
	)
  
	# =============================================================================
	# UNLINK ACCOUNTS =============================================================
	# =============================================================================
	# used to unlink accounts. for social accounts, just remove the token
	# for local account, remove email and password
	# user account will stay active in case they want to reconnect in the future
  
	# local -----------------------------------
	app.get "/unlink/local", isLoggedIn, (req, res) ->
	user = req.user
	user.local.email = `undefined` # erase
	user.local.password = `undefined` # erase
	user.save (err) ->
		res.redirect "/profile"
		return

		return

  
	# facebook -------------------------------
	app.get "/unlink/facebook", isLoggedIn, (req, res) ->
	user = req.user
	user.facebook.token = `undefined`
	user.save (err) ->
		res.redirect "/profile"
		return

	return

return