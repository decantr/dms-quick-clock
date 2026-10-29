# Quick Clock

A bar widget for [Dux Material Shell](https://danklinux.com/docs/dankmaterialshell) with a clock and a stopwatch.

## Install

```bash
./install.sh
dms ipc call plugins enable quickClock
```

Then add **Quick Clock** to a bar in **Settings → Widgets**.

## Usage

- The bar shows the time. Click it to open the popout.
- The popout ticks every second while open and shows a stopwatch with laps.
- While the stopwatch has time, the bar shows the elapsed time instead of the clock.
- The stopwatch keeps running when the popout is closed and across shell restarts.

Turn on **Seconds in bar** in the plugin settings to tick every second in the bar.
