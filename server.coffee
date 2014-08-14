# server.js

# set up ======================================================================
# get all the tools we need
express = require("express")
app = express()
port = process.env.PORT or 8080
mongoose = require("mongoose")
passport = require("passport")
flash = require("connect-flash")
morgan = require("morgan")
cookieParser = require("cookie-parser")
bodyParser = require("body-parser")
session = require("express-session")
configDB = require("./config/database.js")

# configuration ===============================================================
mongoose.connect "mongodb://localhost/store" # connect to our database
require("./config/passport") passport # pass passport for configuration

# set up our express application
app.use morgan("dev") # log every request to the console
app.use cookieParser() # read cookies (needed for auth)
app.use bodyParser() # get information from html forms
app.set "view engine", "ejs" # set up ejs for templating

# required for passport
app.use session(secret: "pornografiecabalina") # session secret
app.use passport.initialize()
app.use passport.session() # persistent login sessions
app.use flash() # use connect-flash for flash messages stored in session

# routes ======================================================================
require("./app/routes.js") app, passport # load our routes and pass in our app and fully configured passport

# launch ======================================================================
app.listen port
console.log "The magic happens on port " + port