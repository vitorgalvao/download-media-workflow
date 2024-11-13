# Frequently Asked Questions (FAQ)

### Why is the download failing?

It is likely that your installation of [`yt-dlp`](https://github.com/yt-dlp/yt-dlp) is outdated. [Update the dependencies](https://www.alfredapp.com/help/kb/dependencies/) and try again.

If the download still fails, [open a terminal](https://support.apple.com/en-gb/guide/terminal/apd5265185d-f365-44cb-8b09-71a064a42125/mac) and run the following (replace `YOUR/URL/HERE` within the quotes with the failing URL):

```console
PATH="/opt/homebrew/bin:/usr/local/bin:${PATH}"
yt-dlp "YOUR/URL/HERE"
```

Then report the error on [the yt-dlp issue tracker](https://github.com/yt-dlp/yt-dlp/issues/new/choose), as they’re the ones who’ll be able to fix the issue. The workflow relies on that tool for the downloads.

### How do I report a different issue?

Accurate and thorough information is crucial for a proper diagnosis. When reporting issues, please include your *exact* installed versions of:

* The Workflow.
* Alfred.
* macOS.

In addition to:

* The [debugger](https://www.alfredapp.com/help/workflows/advanced/debugger/) output. Perform the failing action and click *Copy* on the top right.
* Details on what you did, what happened, and what you expected to happen. A [short video](https://support.apple.com/en-us/HT208721) of the steps with the debugger open may help to find the problem faster.
