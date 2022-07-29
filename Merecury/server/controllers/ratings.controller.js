const pool = require("../db")

// const film = require('../models/film.model')
const getUserFilmratings = async (req, res) => {
    try {
        const { name } = req.params;
        if(req.session.user == name) {
            const allRatings = await pool.query("SELECT * FROM getFilmratings() WHERE username = $1 ORDER BY rating DESC;",[name]);
            const filmSugg = await pool.query("SELECT * FROM getFilmSuggestions($1) ORDER BY name;",[name]);
            res.render("../views/pages/userRatingmgtPage.ejs", {userData: allRatings.rows, suggestFilmData: filmSugg.rows, username: req.session.user});
        }
        else{
            res.redirect('/get/login/page');
        }
    } catch (error) {
        res.status(400).json({ success: false, error });
    }
}


const createFilmratings = async (req, res) => {
    try {
        const { id } = req.params;
        const { username, star, movieReview} = req.body;
        const newRating = await pool.query("SELECT * FROM insertFilmratings($1,$2,$3,$4)",[id, username, star, movieReview]);
        res.redirect('/get/film/id='+id);
    } catch (error) {
        res.status(400).json({ success: false, error });
    }
}

const updateUserFilmratings = async (req, res) => {
    try {
        const { name } = req.params;
        const { editfilmname, star, editmovieReview } = req.body;
        const updateRating = await pool.query("SELECT * FROM updateFilmratings($1,$2,$3,$4)",[name, editfilmname, star, editmovieReview]);
        res.redirect('/user/rating/name='+name);
    } catch (error) {
        res.status(400).json({ success: false, error });
    }
}

const deleteUserFilmpratings = async (req, res) => {
    try {
        const { name, filmname } = req.params;
        const deleteFilm = await pool.query("SELECT * FROM deleteFilmratings($1,$2)", [name, filmname]);
        var curitem = deleteFilm.rows[0]["output"];
        res.redirect('/user/rating/name='+name);
    } catch (error) {
        res.status(400).json({ success: false, error });
    }
}

module.exports = {
    getUserFilmratings,
    createFilmratings,
    updateUserFilmratings,
    deleteUserFilmpratings,
  }