# Zhilu Yang — Compact Academic Homepage

Design:
- one centered global content column;
- compact identity/contact header;
- plain section headings;
- project rows with image on the left and text on the right;
- no photographs, CV button, badges, pills, cards, status icons, or oversized title.

## Deploy from Terminal

```zsh
brew install gh
gh auth login --web --git-protocol https

chmod +x deploy.zsh
./deploy.zsh "/Users/yangyi/Desktop/Zhilu_Yang_Research_Profile_Compact_20260731.zip"
```

The script:
1. extracts and locally previews the site;
2. creates or updates `ada-zy2425/ada-zy2425.github.io`;
3. pushes `index.html` and assets to the `main` branch;
4. enables GitHub Pages from `main / (root)` when needed;
5. opens the Pages settings page.

Published address: `https://ada-zy2425.github.io/`


## Browser tab icon

No custom favicon is included. Browsers use their default page icon.
