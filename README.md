# Project 6 - TranslateMe

Submitted by: **Sijan Shrestha**

**TranslateMe** is a SwiftUI translation app that lets users enter text, translate it with the MyMemory API, and keep a persistent history of translation results using Firestore.

Time spent: **6.5** hours spent in total

## Required Features

The following **required** functionality is completed:

- [x] Users open the app to a TranslationMe home page with a place to enter a word, phrase or sentence, a button to translate, and another field that should initially be empty
- [x] When users tap translate, the word written in the upper field translates in the lower field. The requirement is only that you can translate from one language to another.
- [x] A history of translations can be stored (in a scroll view in the same screen, or a new screen)
- [x] The history of translations can be erased
 
The following **optional** features are implemented:

- [x] Add a variety of choices for the languages
- [x] Add UI flair

The following **additional** features are implemented:

- [x] Fallback local persistence with `UserDefaults` when Firestore is not configured, so testing can still continue without blocking app flow
- [x] Basic loading state and error handling for translation requests

## Video Walkthrough

Here's a walkthrough of implemented user stories:


https://github.com/user-attachments/assets/f00bc87d-1d47-49e3-b276-ea130c50cc71



## Notes

A few implementation details took extra care:

- MyMemory returns nested JSON, so decoding and request encoding had to be validated for punctuation and spaces.
- Firestore setup can fail if project configuration is incomplete, so I added a local fallback store to keep development moving while still supporting Firestore persistence.
- I kept the design intentionally simple and readable with native SwiftUI styles and restrained spacing to keep the interface clean.

## License

    Copyright 2026 Sijan Shrestha

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
