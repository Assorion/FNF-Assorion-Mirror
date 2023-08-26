# Friday Night Funkin' MKG Engine.

![MKG](https://github.com/Legendary-Candice-Joe/Funkin-MKG/assets/105545224/5e5867ae-d7fa-41b3-8cc5-09f993349c48)

## What does it stand for?

The answer: I have no idea.
It's all up to interpretation.

It could stand for:

1. Mario Kart Gamers,
2. MaKe me Genius (what it was meant to stand for (LOL)),
3. ~~Mahistian vs Klahristadian Game (Fnf mod)~~ canned lol I stopped working on it,
4. Etc

## What is it for?

This is virtually the Arch Linux of FNF Engines,
or at least... I hope for it to be.

It is a minimalist engine where I cut out all the fat of
the original game and try my hardest to re-write everything.

There is NO mods folder and will never be one. If you want cutscenes?
You add them yourself. If you want some cool effect? Add it yourself.
As such, the only base game assets are ones that are for week 1.

My goal is a super optimized engine where it should be able to consistantly
reach a high framerate (800 or more on my computer with a 1440p monitor) without
dipping FPS too much, and being able to run on super old computers (Windows XP / 2000).

## This engine is missing features, is hard to work on, etc, etc, blah, blah - You.

Yeah that's fine. You don't have to use this.

This is my SELFISH engine. I want to build my mods the way I want.
So I don't really care what other people think, this engine is designed for me
and isn't even really meant to be public.

Now of course! I understand that I'm not perfect, but no-one is.
There will still be bad code from time to time (chartingstate moment),
But this ***should*** still be far more readable than the original code.

# Important Notes.

1. The settings are stored in a JSON file. (Assets/songs-data/savedata.json)
This means that you can easily modify the settings but also means (atleast for now)
it doesn't work with a web browser. Highscores will still be saved though.
2. Chartingstate is entirely redone. So there is probably new bugs and it will not
be too fast, and also a little confusing to people.
3. On the topic of charts they are handled far differently than the base games.
They work with absolute positions rather than milisecond values. And also notes
have a player value in the chart.
4. **Technically** it should be easy to add more characters in one song. I've made
sure that notes have a special player value, who knows where this can go.
5. No DiscordRPC. Personally I just don't care about it but once again if you want it,
you can add it in yourself.
6. Windows XP? Well no. This engine can't exactly be compiled for XP. But I do plan
on making a port with most of it's features, that will be later though.
7. This is based off of the 0.2.6 version. Yup. Before week 6 was even a thing lol.
8. Songs and Data folder have been merged into the songs-data folder. 

## Screenshots ?

Take a look at art/screenshots.md please.

# Compiling.

I really don't have much to say here. Just read the base game compiling thing for
instructions on it.

I've tested with flixel 4.11.0 and 5.0.0 with no problem.
I have not tested a web build yet, so I have no idea if that works.
That being said I don't really like web builds, it's a pretty bad way
to play this game.

I get that a lot of people need web builds but for me that will be a last priority.
