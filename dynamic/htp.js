var DiffCalc = {
    maxDiff: 10,
    avgDiff: 7.69,
    multiDiff: 4,
    trillDiff: 0,
    ver: "0.22a",
    mod: "insane",
    br: "dev",
    recentChanges: [
        "Cleaning code",
        "Revised difficulty on HTPscreen",
        "Preparing for public release"
    ],
	create: function(){
		return this;
	},
	album: function(el){
        el.getElementsByTagName("img")[0].src = "dynamic/imgs/uigraphic.jpg";
		var limg = document.createElement("img");
		limg.className = "mapperLogo";
		limg.src = "dynamic/imgs/lDiscookie.png";
		el.appendChild(limg);
        
        var t = document.createElement("h1");
        t.appendChild(document.createTextNode("INSANE MOD"));
        t.className = "modtext";
        el.appendChild(t);
		
		var dv = el.getElementsByTagName("div")[0];
        dv.appendChild(document.createElement("br"));
		t = document.createElement("p");
        t.appendChild(document.createTextNode("Less impossible notes!"));
        t.appendChild(document.createElement("br"));
        t.appendChild(document.createTextNode("Static seeds!"));
        t.appendChild(document.createElement("br"));
        t.appendChild(document.createTextNode("Reversed double notes!"));
        t.appendChild(document.createElement("br"));
        t.appendChild(document.createTextNode("And more..."));
		dv.appendChild(t);
	},
	difficulties: function(el){
		var diffs = document.createElement("div");
		diffs.className = "diffWindow";
		el.appendChild(diffs);
		
		var overall = document.createElement("h1");
		overall.className = "yd diff";
		var t = document.createTextNode((Math.round(this.maxDiff*this.avgDiff*(2+this.multiDiff/10)*10/(this.trillDiff/10+1))/100).toFixed(2));
        var y = document.createElement("small");
        y.appendChild(document.createTextNode("overall: "));
        overall.appendChild(y);
		overall.appendChild(t);
		diffs.appendChild(overall);
		
		// Max diff
		var maxSlider = document.createElement("div");
		maxSlider.className = "maxbg slidr";
        // Avg diff
		var avgSlider = document.createElement("div");
		avgSlider.className = "avgbg slidr";
        // Multi diff
		var multiSlider = document.createElement("div");
		multiSlider.className = "multibg slidr";
        // Trill diff
		var trillSlider = document.createElement("div");
		trillSlider.className = "trillbg slidr";
		
		diffs.appendChild(maxSlider);
		diffs.appendChild(avgSlider);
		diffs.appendChild(multiSlider);
		diffs.appendChild(trillSlider);
		
		var maxDisplay = document.createElement("div");
		t = document.createTextNode(this.maxDiff);
		maxDisplay.className = "maxinner slin";
		maxDisplay.style = "width: "+Math.floor(this.maxDiff*250/16)+"px;";
		maxDisplay.appendChild(t);
		maxSlider.appendChild(maxDisplay);
		
		var avgDisplay = document.createElement("div");
		t = document.createTextNode(this.avgDiff);
		avgDisplay.className = "avginner slin";
		avgDisplay.style = "width: "+Math.floor(this.avgDiff*250/10)+"px;";
		avgDisplay.appendChild(t);
		avgSlider.appendChild(avgDisplay);
		
		var multiDisplay = document.createElement("div");
		t = document.createTextNode(this.multiDiff);
		multiDisplay.className = "multiinner slin";
		multiDisplay.style = "width: "+Math.floor(this.multiDiff*250/10)+"px;";
		multiDisplay.appendChild(t);
		multiSlider.appendChild(multiDisplay);
		
		var trillDisplay = document.createElement("div");
		t = document.createTextNode(this.trillDiff);
		trillDisplay.className = "trillinner slin";
		trillDisplay.style = "width: "+Math.floor((10-(this.trillDiff)*50)*250/10)+"px;";
		trillDisplay.appendChild(t);
		trillSlider.appendChild(trillDisplay);
        
        t = document.createElement("div");
        t.className = "maxtx";
        var u = document.createTextNode("MAX");
        t.appendChild(u);
        maxSlider.appendChild(t);
        
        t = document.createElement("div");
        u = document.createTextNode("AVG");
        t.className = "avgtx";
        t.appendChild(u);
        avgSlider.appendChild(t);
        
        t = document.createElement("div");
        u = document.createTextNode("MULTI");
        t.className = "multitx";
        t.appendChild(u);
        multiSlider.appendChild(t);
        
        t = document.createElement("div");
        u = document.createTextNode("SPACING");
        t.className = "trilltx";
        t.appendChild(u);
        trillSlider.appendChild(t);
		
		var stats = document.createElement("p");
		t = document.createElement("br");
		stats.appendChild(t);
		t = document.createTextNode("length: "+this.formattedLength);
		stats.appendChild(t);
		t = document.createElement("br");
		stats.appendChild(t);
		t = document.createTextNode("total notes: "+this.totalNotes);
		stats.appendChild(t);
		t = document.createElement("br");
		stats.appendChild(t);
		t = document.createTextNode("- doubles: "+this.doubles);
		stats.appendChild(t);
		t = document.createElement("br");
		stats.appendChild(t);
		t = document.createTextNode("- purples: "+this.purples);
		stats.appendChild(t);
		el.appendChild(stats);
	},
    testMsgs: {test: "TESTING", nc: "NO CHANGE", nw: "NOT WORKING"},
	density: function(el){
        var resp  = '' ;
        var xmlHttp = new XMLHttpRequest();
        
        var t = document.createElement("h1");
        t.className = "modtext";
		var stats = document.createElement("p");

        if(xmlHttp != null)
        {
            xmlHttp.open( "GET", "https://matekos17.f.fazekas.hu/shield/pings/vercheck?mod="+this.mod+"&ver="+this.br, false );
            if (xmlHttp.status==200) {
                xmlHttp.send( null );
                resp = xmlHttp.responseText;
                if (resp.localeCompare(this.ver)==0 && this.br!="dev") {
                    el.getElementsByTagName("img")[0].src = "dynamic/imgs/green.png";
                    t.appendChild(document.createTextNode("LATEST"));
                    stats.appendChild(document.createTextNode("Thank you for playing!"));
                } else if (resp.localeCompare(this.ver)<0) {
                    el.getElementsByTagName("img")[0].src = "dynamic/imgs/yellow.png";
                    t.appendChild(document.createTextNode("UPDATE"));
                    stats.appendChild(document.createTextNode("New version: "+resp));
                } else {
                    el.getElementsByTagName("img")[0].src = "dynamic/imgs/blue.png";
                    t.appendChild(document.createTextNode("DEV"));
		            stats.appendChild(document.createTextNode("Thank you for testing!"));
                }
            } else {
                el.getElementsByTagName("img")[0].src = "dynamic/imgs/red.png";
                t.appendChild(document.createTextNode("ERROR"));
            }
        } else {
            el.getElementsByTagName("img")[0].src = "dynamic/imgs/blue.png";
            t.appendChild(document.createTextNode("ERROR"));
        }

        el.appendChild(t);
		stats.appendChild(document.createTextNode("Version "+this.ver));
		stats.appendChild(document.createElement("br"));
		stats.appendChild(document.createElement("b").appendChild(document.createTextNode("CHANGELOG:")));
		stats.appendChild(document.createElement("br"));
        for (var i = 0; i < this.recentChanges.length; i++) {
            stats.appendChild(document.createTextNode(" - "+this.recentChanges[i]));
            stats.appendChild(document.createElement("br"));
        }
		el.appendChild(stats);
	}
};

var dc = DiffCalc.create();

dc.album(document.getElementById("album"));
dc.difficulties(document.getElementById("diffs"));
dc.density(document.getElementById("density"));
