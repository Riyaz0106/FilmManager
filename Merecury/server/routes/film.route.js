const express = require("express");
const router = express.Router();
const filmController = require('../controllers/films.controller');
const filmPersoncontroller = require('../controllers/filmpersons.controller');
const filmRatingscontroller = require('../controllers/ratings.controller');
const UserAccountcontroller = require('../controllers/user.controller');

router.get('/get/films', filmController.getFilms);

router.get('/get/film/id=:id', filmController.getFilmbyId);

router.post('/add/film', filmController.createFilm);

router.post('/update/film/id=:id', filmController.updateFilm);

router.delete('/delete/film/id=:id', filmController.deleteFilm);

router.get('/get/filmpersons', filmPersoncontroller.getFilmpersons);

router.post('/add/filmpersons', filmPersoncontroller.createFilmpersons);

router.put('/update/filmpersons/id=:id', filmPersoncontroller.updateFilmpersons);

router.delete('/delete/filmpersons/id=:id', filmPersoncontroller.deleteFilmpersons);

router.post('/add/rating/id=:id', filmRatingscontroller.createFilmratings);

router.get('/user/rating/name=:name', filmRatingscontroller.getUserFilmratings);

router.put('/update/rating/name=:name', filmRatingscontroller.updateUserFilmratings);

router.delete('/delete/rating/filmname=:filmname/name=:name', filmRatingscontroller.deleteUserFilmpratings);

router.get('/get/login/page', UserAccountcontroller.getloginPage);

router.post('/user/login', UserAccountcontroller.login);

router.post('/user/signup', UserAccountcontroller.signup);

router.post('/user/logout', UserAccountcontroller.logout);

module.exports = router;