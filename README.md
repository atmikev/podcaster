# podcaster
My little podcasting app (technically a podcatcher, but I don't like that term). Don't have enough time to focus on it right now as I'm spending all my time on www.dryv.com. Feel free to fork/contribute. 

Two features I like about this app:
* It always shows the most recent episode of your subscriptions
* It is capable of showing interactive links as the images for the episode. These come in the form of TMMarks, which have a time, image, and link. When the TMAudioPlayerManager shows a TMMark, it changes the image in the TMAudioPlayerViewController to show the image, which can be tapped to link out to whatever link you want. The idea is that podcast producers would use a website (that I haven't built yet) to upload the information for all the marks. That way they can still distribute their podcasts normally (i.e. iTunes, Feedburner, whatever), and we'd be able to download the Marks seperately and sync them up with the audio. See https://www.youtube.com/watch?v=2Q7tcj-2Z98 for a (hardcoded) demo and the MarksMVP branch for details.

tyler@dryv.com if you have any question!
