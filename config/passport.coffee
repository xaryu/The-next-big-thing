# load all the things we need
LocalStrategy = require("passport-local").Strategy
FacebookStrategy = require("passport-facebook").Strategy

# load up the user model
User = require("../app/models/user")

# load the auth variables
configAuth = require("./auth") # use this one for testing
module.exports = (passport) ->
  
  # =========================================================================
  # passport session setup ==================================================
  # =========================================================================
  # required for persistent login sessions
  # passport needs ability to serialize and unserialize users out of session
  
  # used to serialize the user for the session
  passport.serializeUser (user, done) ->
    done null, user.id
    return

  
  # used to deserialize the user
  passport.deserializeUser (id, done) ->
    User.findById id, (err, user) ->
      done err, user
      return

    return

  
  # =========================================================================
  # LOCAL LOGIN =============================================================
  # =========================================================================
  passport.use "local-login", new LocalStrategy(
    
    # by default, local strategy uses username and password, we will override with email
    usernameField: "email"
    passwordField: "password"
    passReqToCallback: true # allows us to pass in the req from our route (lets us check if a user is logged in or not)
  , (req, email, password, done) ->
    email = email.toLowerCase()  if email #convert to lower case email
    
    # asynchronous
    process.nextTick ->
      User.findOne
        "local.email": email
      , (err, user) ->
        
        # if there are any errors, return the error
        return done(err)  if err
        
        # if no user is found, return the message
        return done(null, false, req.flash("loginMessage", "No user found."))  unless user
        unless user.validPassword(password)
          done null, false, req.flash("loginMessage", "Oops! Wrong password.")
        
        # all is well, return user
        else
          done null, user

      return

    return
  )
  
  # =========================================================================
  # LOCAL SIGNUP ============================================================
  # =========================================================================
  passport.use "local-signup", new LocalStrategy(
    
    # by default, local strategy uses username and password, we will override with email
    usernameField: "email"
    passwordField: "password"
    passReqToCallback: true # allows us to pass in the req from our route (lets us check if a user is logged in or not)
  , (req, email, password, done) ->
    email = email.toLowerCase()  if email #convert email to lower case
    
    # asynchronous
    process.nextTick ->
      
      #if the user is not already logged in:
      unless req.user
        User.findOne
          "local.email": email
        , (err, user) ->
          
          # if there are any errors, return the error
          return done(err)  if err
          
          # check to see if there's already a user with that email
          if user
            done null, false, req.flash("signupMessage", "That email is already taken.")
          else
            
            #create the user
            newUser = new User()
            newUser.local.email = email
            newUser.local.password = newUser.generateHash(password)
            newUser.save (err) ->
              throw err  if err
              done null, newUser

          return

      
      #if the user is logged in but has no local account
      else
        User.findOne
          "local.email": email
        , (err, emailexists) ->
          unless emailexists
            console.log "nu exista cont"
            user = req.user
            user.local.email = email
            user.local.password = user.generateHash(password)
            user.save (err) ->
              throw err  if err
              done null, user

          else
            
            #MUST VALIDATE PASSWORD HERE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            console.log "exista cont"
            user = req.user
            user.local.email = emailexists.local.email
            user.local.password = emailexists.local.password
            user.save (err) ->
              throw err  if err
              done null, user

          return

      return

    return
  )
  
  # =========================================================================
  # FACEBOOK ================================================================
  # =========================================================================
  passport.use new FacebookStrategy(
    clientID: configAuth.facebookAuth.clientID
    clientSecret: configAuth.facebookAuth.clientSecret
    callbackURL: configAuth.facebookAuth.callbackURL
    passReqToCallback: true # allows us to pass in the req from our route (lets us check if a user is logged in or not)
  , (req, token, refreshToken, profile, done) ->
    
    # asynchronous
    process.nextTick ->
      
      # check if the user is already logged in
      unless req.user
        User.findOne
          "facebook.id": profile.id
        , (err, user) ->
          return done(err)  if err
          if user
            
            # if there is a user id already but no token (user was linked at one point and then removed)
            unless user.facebook.token
              user.facebook.token = token
              user.facebook.name = profile.name.givenName + " " + profile.name.familyName
              user.facebook.email = profile.emails[0].value
              user.save (err) ->
                throw err  if err
                done null, user

            done null, user # user found, return that user
          else
            
            # if there is no user, create them
            newUser = new User()
            newUser.facebook.id = profile.id
            newUser.facebook.token = token
            newUser.facebook.name = profile.name.givenName + " " + profile.name.familyName
            newUser.facebook.email = profile.emails[0].value
            newUser.save (err) ->
              throw err  if err
              done null, newUser

          return

      else
        
        # user already exists and is logged in, we have to link accounts
        user = req.user # pull the user out of the session
        user.facebook.id = profile.id
        user.facebook.token = token
        user.facebook.name = profile.name.givenName + " " + profile.name.familyName
        user.facebook.email = profile.emails[0].value
        user.save (err) ->
          throw err  if err
          done null, user

      return

    return
  )
  return