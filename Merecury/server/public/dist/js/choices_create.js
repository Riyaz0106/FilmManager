/* Add film model functions*/
/* Function to create dropdown for film persons and roles */
function createPersonsRolesselect(mdiv, selected=false, selectedpersonslist=[], selectedroleslist=[]){
    if (mdiv === 'addfilmRolePerson_div'){
        var flag = addflag;
    }
    else{
        var flag = editflag;
    }

    var select_div =  document.getElementById(mdiv);

    var newPersonSelect = document.createElement("select");
    var div = document.createElement("div");
    var div1 = document.createElement("div");
    var div2 = document.createElement("div");
    var div3 = document.createElement("div");
    var br = document.createElement("br");

    div.setAttribute("id",mdiv+"_select"+flag);
    div1.setAttribute("class", "row");
    div2.setAttribute("class", "col");
    div3.setAttribute("class", "col");

    select_div.appendChild(div);
    div.appendChild(br);
    div.appendChild(div1);
    div1.appendChild(div2);
    div1.appendChild(div3);

    newPersonSelect.id=mdiv+"_movieperson"+flag;
    newPersonSelect.setAttribute("placeholder","Please select a person"); 
    newPersonSelect.name=mdiv+"_movieperson"+flag;
    newPersonSelect.required = true;
    div2.appendChild(newPersonSelect);

    var newRoleSelect = document.createElement("select");
    newRoleSelect.id=mdiv+"_movierole"+flag;
    newRoleSelect.setAttribute("placeholder","Please select a role");
    newRoleSelect.required = true; 
    newRoleSelect.multiple = true;
    newRoleSelect.name=mdiv+"_movierole"+flag;
    div3.appendChild(newRoleSelect);

    personsChoices = new Choices('#'+mdiv+'_movieperson'+flag, {
        maxItemCount:5,
        searchResultLimit:5,
        placeholder: true
    });

    rolesChoices = new Choices('#'+mdiv+'_movierole'+flag, {
        removeItemButton: true,
        maxItemCount:5,
        searchResultLimit:5,
        placeholder: true
    });

    var personslist = persons_arr.split(",");
    var roleslist = roles_arr.split(",");


    if(selected){
        var persons = generateselectedandunselectedchoices(selectedpersonslist,personslist);
        var roles = generateselectedandunselectedchoices(selectedroleslist,roleslist);
        personsChoices.clearStore();
        rolesChoices.clearStore();
    }
    else{
        var persons = setPersonsRolesselect(personslist);
        var roles = setPersonsRolesselect(roleslist);
    }

    personsChoices.setChoices(persons,'value', 'label',false);

    rolesChoices.setChoices(roles,'value', 'label',false);

    flag+=1;
    if(flag != 0){
        minusbutton =  document.querySelector('#'+mdiv+'_minus_btn');
        minusbutton.disabled = false;
    }
    else{
        minusbutton =  document.querySelector('#'+mdiv+'_minus_btn');
        minusbutton.disabled = true;
    }

    if (mdiv === 'addfilmRolePerson_div'){
        addflag = flag;
    }
    else{
        editflag = flag;
    }

}

/* Function to set dropdown values for film persons and roles */
function setPersonsRolesselect(mlist){
    var items = [];
    // var items1 = [];
    for(var i =0; i<mlist.length;i++){
        var item={}
        item ['value'] = mlist[i];
        item ['label'] = mlist[i];
        items[i]=item;
    }
    return items;
}

/* Function to delete dropdown for film persons and roles */
function deletePersonsRolesselect(mdiv){
    if (mdiv === 'addfilmRolePerson_div'){
        var flag = addflag;
    }
    else{
        var flag = editflag;
    }

    flag-=1;
    var select_div =  document.getElementById(mdiv+"_select"+flag);
    select_div.replaceChildren();
    select_div.remove();
    if(flag != 0){
        minusbutton =  document.querySelector('#'+mdiv+'_minus_btn');
        minusbutton.disabled = false;
    }
    else{
        minusbutton =  document.querySelector('#'+mdiv+'_minus_btn');
        minusbutton.disabled = true;
    }

    if (mdiv === 'addfilmRolePerson_div'){
        addflag = flag;
    }
    else{
        editflag = flag;
    }

}

/* Edit film model functions*/
/* Function to populate genere dropdown and set values to edit fields*/
function setfilmData(movie, mygenereChoices, mysubfilmChoices, supermovie){

    document.getElementById('editmoviename').value = movie[0];
    document.getElementById('editmovieyear').value = movie[1];
    document.getElementById('editmovieSynopsis').value = movie[2];
    document.getElementById('editmovieaudtype').value = movie[3];
    document.getElementById('editmovieduration').value = movie[5];
    // document.getElementById('editmoviesuper').selected = movie[8];

    var selectedgenereList = movie[4].split(",");
    var genereList = ['Fantasy', 'Romance', 'Drama', 'Crime & Mystery', 'Horrer', 'Documentry', 'Sci-Fi', 'Comedy', 'Historical', 'Action', 'Thriller', 'Animation', 'Adventure', 'Strategy']
    
    var generechoices = generateselectedandunselectedchoices(selectedgenereList,genereList)
    mygenereChoices.clearStore();
    mygenereChoices.setChoices(generechoices,'value', 'label', false);
    if(movie[7] != ""){
        var selectedpersonList = movie[6].split(",");
        var selectedroleList = movie[7].slice(1, -1).split('"').join("").split("},{");
        for(var i=0;i<selectedpersonList.length;i++){
            createPersonsRolesselect('editfilmRolePerson_div', true, [selectedpersonList[i]], selectedroleList[i].split(","));
        }
    }

    var allmovielist = movie[8].split(',');
    console.log(allmovielist);
    if(supermovie.length != 0){
        var superfilmchoices = generateselectedandunselectedchoices(supermovie,allmovielist);
        mysubfilmChoices.clearStore();
        mysubfilmChoices.setChoices(superfilmchoices,'value', 'label', false);
    }

}

function generateselectedandunselectedchoices(selected,unselected){
    var items = [];
    unselected.forEach(unelement => {
        var item={}
        item ['value'] = unelement;
        item ['label'] = unelement;
        selected.forEach(selelement => {
        if(unelement==selelement){
            item ['selected'] = true;
        } 
        });
        items.push(item);
    });
    return items;
}