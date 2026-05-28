=== README.md ===

# Backtest Pro Mobile - Flutter Edition

A complete Flutter port of the Backtest Pro Mobile trading backtesting application.

## Features

- Bar-by-bar replay (Prev/Next/Latest buttons)
- 6 Drawing tools (Trend, H-Line, V-Line, Box, Fibonacci, Cursor)
- Data-coordinate storage (drawings persist as bar_index, price)
- Multi-timeframe persistence (same CSV = same drawings)
- Dataset-scoped drawings (different CSV = fresh drawing set)
- Trade simulation (BUY/SELL with lot sizing)
- Real-time P&L tracking (pips and USD)
- CSV import (paste text or file path)
- Asset auto-categorization (FOREX, CRYPTO, COMMODITIES, FUTURES)
- Theme toggle (Dark/Light mode)
- Custom Canvas rendering with Flutter CustomPainter
- Snap-to-bar/price behavior (TradingView-like)
- Editable handles and drag-to-move

## Quick Start

1. Tap "LOAD CSV" to load data (sample EURUSD included)
2. Use PREV/NEXT/LATEST to navigate bars
3. Select a drawing tool, touch and drag on chart
4. Use Cursor tool to select and edit drawings
5. Tap BUY/SELL to simulate trades

## CSV Format

```csv
Date,Open,High,Low,Close,Volume
2024-01-01,1.1000,1.1050,1.0980,1.1030,15000
```

## Build APK

This repository includes a GitHub Actions workflow. Push to main branch or go to Actions tab and click "Run workflow" to build the APK automatically.

## License

Same as original Backtest Pro project.
