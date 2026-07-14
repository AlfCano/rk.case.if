// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!



function preprocess(is_preview){
	// add requirements etc. here
	echo("require(dplyr)\n");
}

function calculate(is_preview){
	// read in variables from dialog


	// the R code to be evaluated
	
    function getCol(id) {
        var raw = getValue(id);
        if (!raw) return 'NULL';
        var parts = raw.split(/[\[\]\$]+/).filter(Boolean);
        if (parts.length > 0) {
            var last = parts[parts.length - 1];
            return last.replace(/["']/g, '');
        }
        return raw;
    }

    function getCleanArray(id) {
        var rawValue = getValue(id);
        if (!rawValue) return [];
        var raw = rawValue.split(/\n/).filter(Boolean);
        return raw.map(function(item) {
            return item.replace(/[\n\r]/g, '');
        });
    }
  
	
    var df = getValue('bas_df'); if(!df) return;
    var v = getCol('bas_var');
    var cond = getValue('bas_cond');
    var val = getValue('bas_val');
    var is_txt = getValue('bas_text_chk') === '1';

    var t_val = getValue('bas_true');
    var f_val = getValue('bas_false');
    var out_txt = getValue('bas_out_text') === '1';
    var out_name = getValue('bas_outname');

    var val_str = is_txt ? "'" + val + "'" : val;
    var t_str = out_txt ? "'" + t_val + "'" : t_val;
    var f_str = out_txt ? "'" + f_val + "'" : f_val;

    var c_code = '';
    if(cond === 'is.na') c_code = 'is.na(' + v + ')';
    else if(cond === 'is.numeric') c_code = 'is.numeric(' + v + ')';
    else if(cond === 'is.character') c_code = 'is.character(' + v + ')';
    else if(cond === 'grepl') c_code = 'grepl(' + val_str + ', ' + v + ')';
    else c_code = v + ' ' + cond + ' ' + val_str;

    echo("recoded_df <- " + df + " %>%\n");
    echo("  dplyr::mutate(\n");
    echo("    `" + out_name + "` = dplyr::if_else(" + c_code + ", " + t_str + ", " + f_str + ")\n");
    echo("  )\n");
  
}

function printout(is_preview){
	// printout the results
	new Header(i18n("Basic Recoder results")).print();
	
    var save = getValue('bas_save');
    echo("rk.header('Basic If/Else Recoder')\n");
    echo("rk.print('Data successfully saved to object: " + save + "')\n");
    echo("rk.results(head(recoded_df))\n");
  
	//// save result object
	// read in saveobject variables
	var basSave = getValue("bas_save");
	var basSaveActive = getValue("bas_save.active");
	var basSaveParent = getValue("bas_save.parent");
	// assign object to chosen environment
	if(basSaveActive) {
		echo(".GlobalEnv$" + basSave + " <- recoded_df\n");
	}

}

