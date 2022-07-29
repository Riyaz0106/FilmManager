const pool = require("../db")

// const film = require('../models/film.model')

const getloginPage = async (req, res) => {
    try {
        if(req.session.user){
            res.redirect('/user/rating/name='+req.session.user);
        }else{
            res.render("../views/pages/login.ejs");
        }
    } catch (error) {
        res.status(400).json({ success: false, error });
    }
}

const login = async (req, res) => {
    try {
        const { loginuserName, loginpassword } = req.body;
        const createuser = await pool.query("SELECT * FROM getuser($1, $2);", [loginuserName, loginpassword]);
        if (createuser.rows[0]["output"] == 'Found'){
            req.session.user = req.body.loginuserName;
            res.redirect('/user/rating/name='+loginuserName);
        }
        else{
            res.redirect('/get/login/page'+'?msg='+createuser.rows[0]["output"]);
        }
    } catch (error) {
        res.status(400).json({ success: false, error });
    }
}

const signup = async (req, res) => {
    try {
        const { signupuserName, signuppassword, signuprepassword } = req.body;
        const createuser = await pool.query("SELECT * FROM createuser($1, $2, $3);", [signupuserName, signuppassword, signuprepassword]);
        res.redirect('/get/login/page'+'?msg='+createuser.rows[0]["output"]);
    } catch (error) {
        res.status(400).json({ success: false, error });
    }
}

const logout = async (req, res) => {
    try {
        if(req.session.user){
            req.session.destroy();
        }
        res.render("../views/pages/login.ejs");
    } catch (error) {
        res.status(400).json({ success: false, error });
    }
}

module.exports = {
    getloginPage,
    login,
    signup,
    logout
  }