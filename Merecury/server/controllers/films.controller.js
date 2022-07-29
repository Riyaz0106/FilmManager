const pool = require("../db")

// const film = require('../models/film.model')

const getFilms = async (req, res) => {
    try {
        const superFilms = await pool.query("SELECT * FROM getAllSuperFilms() ORDER BY releaseyear, name;");
        const allFilmsnames = await pool.query("SELECT id, name FROM getFilms();");
        res.render("../views/pages/index.ejs", {filmData: superFilms.rows, filmData1: allFilmsnames.rows});
    } catch (error) {
        res.status(400).json({ success: false, error });
    }
}

const getFilmbyId = async (req, res) => {
    try {
        const { id } = req.params;
        const film = await pool.query("SELECT * FROM getFilmswithPersonsRoles() WHERE id = $1;", [id]);
        const subfilms = await pool.query("SELECT * FROM getsubfilmlink($1) ORDER BY releaseyear, name;", [id]);
        const ratings = await pool.query("SELECT * FROM getFilmratings() WHERE filmname = $1 ORDER BY username;",[film.rows[0]["name"]])
        const avgratings = await pool.query("SELECT * FROM calculateaverageRating($1);",[film.rows[0]["name"]])
        res.render("../views/pages/filmPage.ejs", {filmData: subfilms.rows, filmData1: film.rows, ratingData: ratings.rows, averagerating: avgratings.rows[0]["_out"]})
    } catch (error) {
        res.status(400).json({ success: false, error });
    }
}

const createFilm = async (req, res) => {
    try {
        const {moviename,movieyear,movieSynopsis,movieaudtype,moviegenere,movieduration,moviesuper} =req.body;
        const newFilm = await pool.query('SELECT * FROM insertFilm($1, $2,$3,$4,$5,$6)',[moviename,movieyear,movieSynopsis,movieaudtype,moviegenere,movieduration]);
        var curitem = newFilm.rows[0]["insertfilm"];
        if(newFilm.rowCount != 0){            
            const addperson = await pool.query('SELECT * FROM insertPersonFilmRoles($1)',[JSON.stringify(req.body)]);
            if(addperson.rows[0]["insertPersonFilmRoles"] == 'added'){
                const addsubfilmlink = await pool.query('SELECT * FROM createsubfilmlink($1,$2)',[moviesuper,curitem]);
            }
            res.redirect('/get/films?msg=Film Inserted');
        }
    } catch (error) {
        res.status(400).json({ success: false, error });
    }
}

const updateFilm = async (req, res) => {
    try {
        const{ id } = req.params;
        const {editmoviename,editmovieyear,editmovieSynopsis,editmovieaudtype,editmovieduration,editmoviesuper} =req.body;
        const editmoviegenere = req.body["editmoviegenere"].join(',');
        const updateFilm = await pool.query("SELECT * FROM updateFilmbyId($1,$2,$3,$4,$5,$6,$7)",[id,editmoviename,editmovieyear,editmovieSynopsis,editmoviegenere,editmovieaudtype,editmovieduration]);
        var curitem = updateFilm.rows[0]["updatefilmbyid"];
        // if(curitem == "updated"){
            const updatesubfilmlink = await pool.query('SELECT * FROM updatesubfilmlink($1,$2)',[editmoviesuper,id]);

            const deleteperson = await pool.query('SELECT * FROM deleteFilmPersonfilmroles($1)',[editmoviename]);
            curitem = deleteperson.rows[0]["output"];
            if(curitem == "deleted"){
                const updateperson = await pool.query('SELECT * FROM insertPersonFilmRoles($1)',[JSON.stringify(req.body)]);
            }
            
            res.redirect('/get/films');
        // }
    } catch (error) {
        res.status(400).json({ success: false, error });
    }
}

const deleteFilm = async (req, res) => {
    try {
        const { id } = req.params;
        const deleteFilm = await pool.query("SELECT * FROM deleteFilmbyId($1)", [id]);
        
        var curitem = deleteFilm.rows[0]["output"];
        res.redirect('/get/films');
    } catch (error) {
        res.status(400).json({ success: false, error });
    }
}

module.exports = {
    getFilms,
    getFilmbyId,
    createFilm,
    updateFilm,
    deleteFilm,
  }