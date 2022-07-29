const pool = require("../db")

// const film = require('../models/film.model')
const getFilmpersons = async (req, res) => {
    try {
        const allPersons = await pool.query("SELECT * FROM getFilmpersons() ORDER BY name;");
        res.render("../views/pages/filmPersonsPage.ejs", {filmData: allPersons.rows});
    } catch (error) {
        res.status(400).json({ success: false, error });
    }
}

const createFilmpersons = async (req, res) => {
    try {
        const { name, age, gender, experience } = req.body;
        const newPerson = await pool.query("SELECT * FROM insertFilmpersons($1,$2,$3,$4)",[name, age, gender, experience]);
        res.redirect('/get/filmpersons');
    } catch (error) {
        res.status(400).json({ success: false, error });
    }
}

const updateFilmpersons = async (req, res) => {
    try {
        const { id } = req.params;
        const { editpersonname, editpersonage, editpersongender, editpersonexperience } = req.body;
        const updatePerson = await pool.query("SELECT * FROM updateFilmpersonsbyId($1,$2,$3,$4,$5)",[id, editpersonname, editpersonage, editpersongender, editpersonexperience]);
        res.redirect('/get/filmpersons');
    } catch (error) {
        res.status(400).json({ success: false, error });
    }
}

const deleteFilmpersons = async (req, res) => {
    try {
        const { id } = req.params;
        const deleteFilm = await pool.query("SELECT * FROM deleteFilmpersonsbyId($1)", [id]);
        var curitem = deleteFilm.rows[0]["output"];
        res.redirect('/get/filmpersons');
    } catch (error) {
        res.status(400).json({ success: false, error });
    }
}

module.exports = {
    getFilmpersons,
    createFilmpersons,
    updateFilmpersons,
    deleteFilmpersons,
  }