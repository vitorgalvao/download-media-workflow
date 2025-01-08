# Frequently Asked Questions (FAQ)

### Why is the download failing?

It is likely that your installation of [`yt-dlp`](https://github.com/yt-dlp/yt-dlp) is outdated. [Update the dependencies](https://www.alfredapp.com/help/kb/dependencies/) and try again.

If the download still fails, [open a terminal](https://support.apple.com/en-gb/guide/terminal/apd5265185d-f365-44cb-8b09-71a064a42125/mac) and run the following (replace `YOUR/URL/HERE` within the quotes with the failing URL):

```console
PATH="/opt/homebrew/bin:/usr/local/bin:${PATH}"
yt-dlp "YOUR/URL/HERE"
```

Then report the error on [the yt-dlp issue tracker](https://github.com/yt-dlp/yt-dlp/issues/new/choose), as they’re the ones who’ll be able to fix the issue. The workflow relies on that tool for the downloads.

### How do I report an issue?

Accurate and thorough information is crucial for a proper diagnosis. **At a minimum, your report should include:**

* The [debugger](https://www.alfredapp.com/help/workflows/advanced/debugger/) output of the failing action.
* Your installed versions of: the Workflow, Alfred, and macOS. *Be precise, don’t say “latest”.*
