const express = require("express");
const app = express();
const cors = require("cors");
const methodOverride = require('method-override');
const FilmRoutes = require("./routes/film.route")
const cookieParser = require('cookie-parser');
const session = require('express-session');
const favicon = require('serve-favicon');
var path = require('path');
const oneDay = 1000 * 60 * 60 * 24;

app.use(express.static('./public'));

//middleware
app.use(cors());
app.use(express.json()); //req.body
app.use(express.urlencoded({ extended: true }));
app.use(methodOverride('_method'));
app.use(cookieParser());
app.use(session({
  secret: "thisismysecrctekey343ji43j4n3jn4jk3n",
    saveUninitialized:true,
    cookie: { maxAge: oneDay },
    resave: false
  }));

app.use(favicon(path.join(__dirname, 'public/dist/images', 'favicon.ico')));

app.use('/', FilmRoutes);
app.set("views", "./views");
app.get('/', (req, res) => {  
  res.redirect('/get/films');
});

app.listen(5000, () => {
  console.log("server has started on port 5000");
});
