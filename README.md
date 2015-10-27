# podcaster
My little podcasting app (technically a podcatcher, but I don't like that term). Don't have enough time to focus on it right now as I'm spending all my time on www.dryv.com. Feel free to fork/contribute. 

Two features I like about this app:
* It always shows the most recent episode of your subscriptions
* It is capable of showing interactive links as the images for the episode. These come in the form of TMMarks, which have a time, image, and link. When the TMAudioPlayerManager shows a TMMark, it changes the image in the TMAudioPlayerViewController to show the image, which can be tapped to link out to whatever link you want. The idea is that podcast producers would use a website (that I haven't built yet) to upload the information for all the marks. That way they can still distribute their podcasts normally (i.e. iTunes, Feedburner, whatever), and we'd be able to download the Marks seperately and sync them up with the audio. See https://www.youtube.com/watch?v=2Q7tcj-2Z98 for a (hardcoded) demo and the MarksMVP branch for details.

tyler@dryv.com if you have any question!

Ugh it pains me to do this but...

The MIT License (MIT)

Copyright (c) [year] [fullname]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
