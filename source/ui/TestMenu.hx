package ui;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import misc.Alphabet;

class TestMenu extends MenuTemplate {
    override function create(){
        super.create();
        background.color = ChartingState.colorFromRGBArray([255,255,0]);
        adds = [150];
        splitNumb = 1;

        pushObject(new Alphabet(0,0,'gay',true));
        pushObject(new Alphabet(0,0,'2',true));
        pushObject(new Alphabet(0,0,'penis',true));
        pushObject(new Alphabet(0,0,'balls',true));
        pushObject(new Alphabet(0,0,'before',true));
        pushObject(new Alphabet(0,0,'after',true));

        pushIcon(new gameplay.HealthIcon('bf', false));
        pushIcon(new gameplay.HealthIcon('dad', false));
        pushIcon(new gameplay.HealthIcon('gf', false));
        
    }
}