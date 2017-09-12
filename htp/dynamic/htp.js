var DiffCalc = {
    // NO TOUCHY HERE
    ver: "0.50a",
    mod: "insane",
    br: "dev",
    recentChanges: [
        "Full refactor, rework",
        "Include compile tools",
        "",
        "Issues, feature requests on GitHub",
        "Change and test accel/span values",
    ],
    create: function () {
        return this;
    },
    album: function (el) {
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
        t.appendChild(document.createTextNode("Non-centered doubles!"));
        t.appendChild(document.createElement("br"));
        t.appendChild(document.createTextNode("And more..."));
        dv.appendChild(t);
    },
    difficulties: function (el) {
        var diffs = document.createElement("div");
        diffs.className = "diffWindow";
        el.appendChild(diffs);
        var overall = document.createElement("h1");
        var oaVal = (Math.round((Math.pow((diff.maxDiff * (diff.armspan / 1.5)), 0.85) + 3) * Math.pow(diff.avgDiff / 10, 0.6) * (2 + diff.multiDiff / 10) * 100 / (Math.pow(diff.trillDiff * 4, 3) + 1)) / 100).toFixed(2);
        if (oaVal < 15) {
            overall.className = "gd diff";
        } else if (oaVal < 21) {
            overall.className = "yd diff";
        } else if (oaVal < 27) {
            overall.className = "rd diff";
        } else {
            overall.className = "pd diff";
        }
        var t = document.createTextNode(oaVal);
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
        t = document.createTextNode(diff.maxDiff);
        maxDisplay.className = "maxinner slin";
        maxDisplay.style = "width: " + Math.floor(diff.maxDiff * 250 / 16) + "px;";
        maxDisplay.appendChild(t);
        maxSlider.appendChild(maxDisplay);
        var avgDisplay = document.createElement("div");
        t = document.createTextNode(diff.avgDiff);
        avgDisplay.className = "avginner slin";
        avgDisplay.style = "width: " + Math.floor(diff.avgDiff * 250 / 10) + "px;";
        avgDisplay.appendChild(t);
        avgSlider.appendChild(avgDisplay);
        var multiDisplay = document.createElement("div");
        t = document.createTextNode(diff.multiDiff);
        multiDisplay.className = "multiinner slin";
        multiDisplay.style = "width: " + Math.floor(diff.multiDiff * 250 / 10) + "px;";
        multiDisplay.appendChild(t);
        multiSlider.appendChild(multiDisplay);
        var trillDisplay = document.createElement("div");
        t = document.createTextNode(diff.trillDiff);
        trillDisplay.className = "trillinner slin";
        trillDisplay.style = "width: " + Math.floor((10 - (diff.trillDiff) * 50) * 250 / 10) + "px;";
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
        stats.appendChild(document.createElement("br"));
        stats.appendChild(document.createTextNode("Keep in mind that these aren't synced to the LUA file!"));
        stats.appendChild(document.createElement("br"));
        stats.appendChild(document.createTextNode("To get your difficulty, change values in"));
        stats.appendChild(document.createElement("br"));
        stats.appendChild(document.createTextNode("dynamic/htp.js!"));
        el.appendChild(stats);
    },
    testMsgs: {
        test: "TESTING",
        nc: "NO CHANGE",
        nw: "NOT WORKING"
    },
    density: function (el) {
        var resp = '';
        var xmlHttp = new XMLHttpRequest();
        var t = document.createElement("h1");
        t.className = "modtext";
        var stats = document.createElement("p");
        try {
            if (xmlHttp !== null) {
                xmlHttp.open("GET", "http://matekos17.f.fazekas.hu/shield/pings/vercheck?mod=" + this.mod + "&ver=" + this.br, false);
                xmlHttp.send();
                if (xmlHttp.status == 200) {
                    resp = xmlHttp.responseText;
                    if (resp.localeCompare(this.ver) == 0 && this.br == "stable") {
                        el.getElementsByTagName("img")[0].src = "dynamic/imgs/green.png";
                        t.appendChild(document.createTextNode("NO UPDATE"));
                        stats.appendChild(document.createTextNode("Thank you for playing!"));
                    } else if (resp.localeCompare(this.ver) > 0) {
                        el.getElementsByTagName("img")[0].src = "dynamic/imgs/yellow.png";
                        t.appendChild(document.createTextNode("UPDATE"));
                        stats.appendChild(document.createTextNode("New version: "));
                        var link = document.createElement("a");
                        link.className = "button";
                        link.appendChild(document.createTextNode(resp));
                        link.href = "https://matekos17.f.fazekas.hu/shield/download?ver=" + this.br;
                        stats.appendChild(link);
                    } else {
                        el.getElementsByTagName("img")[0].src = "dynamic/imgs/blue.png";
                        t.appendChild(document.createTextNode("DEV"));
                        stats.appendChild(document.createTextNode("Thank you for testing!"));
                    }
                } else {
                    el.getElementsByTagName("img")[0].src = "dynamic/imgs/missing.png";
                    t.appendChild(document.createTextNode("NO INTERNET"));
                }
            } else {
                el.getElementsByTagName("img")[0].src = "dynamic/imgs/missing.png";
                t.appendChild(document.createTextNode("ERROR"));
            }
        } catch (e) {
            el.getElementsByTagName("img")[0].src = "dynamic/imgs/missing.png";
            t.appendChild(document.createTextNode("NO INTERNET"));
        }
        el.appendChild(t);
        stats.appendChild(document.createElement("br"));
        stats.appendChild(document.createTextNode("Version " + this.ver));
        stats.appendChild(document.createElement("br"));
        stats.appendChild(document.createElement("b").appendChild(document.createTextNode("CHANGELOG:")));
        stats.appendChild(document.createElement("br"));
        for (var i = 0; i < this.recentChanges.length; i++) {
            stats.appendChild(document.createTextNode(" - " + this.recentChanges[i]));
            stats.appendChild(document.createElement("br"));
        }
        el.appendChild(stats);
    }
};
var dc = DiffCalc.create();
dc.album(document.getElementById("album"));
dc.difficulties(document.getElementById("diffs"));
dc.density(document.getElementById("density"));
