"""Exercise game-mode transitions without changing the desktop."""

from copy import deepcopy
from pathlib import Path
import runpy
import tempfile
import unittest


helper = runpy.run_path(str(Path(__file__).resolve().parents[1] / "scripts/niri-game-mode"))


class GameModeTests(unittest.TestCase):
    def setUp(self):
        self.state = helper["State"]()
        self.outputs = {"DP-1": {"logical": {"width": 2560, "height": 1440}}}
        self.game = {
            "id": 1,
            "app_id": "gamescope",
            "workspace_id": 3,
            "is_focused": True,
            "layout": {"tile_size": [2560.0, 1440.0], "window_size": [1920, 1080]},
        }
        self.state.update({"WorkspacesChanged": {"workspaces": [{"id": 3, "output": "DP-1"}]}})
        self.state.update({"WindowsChanged": {"windows": [deepcopy(self.game)]}})

    def test_focus_close_overview_and_fullscreen_transitions(self):
        self.assertTrue(self.state.is_gaming(self.outputs))
        for event in (
            {"WindowFocusChanged": {"id": None}},
            {"WindowFocusChanged": {"id": 99}},
            {"OverviewOpenedOrClosed": {"is_open": True}},
            {"WindowLayoutsChanged": {"changes": [[1, {"tile_size": [1900, 1386]}]]}},
            {"WindowClosed": {"id": 1}},
        ):
            with self.subTest(event=event):
                self.setUp()
                self.state.update(event)
                self.assertFalse(self.state.is_gaming(self.outputs))
        self.setUp()
        self.state.update({"OverviewOpenedOrClosed": {"is_open": True}})
        self.state.update({"OverviewOpenedOrClosed": {"is_open": False}})
        self.assertTrue(self.state.is_gaming(self.outputs))

    def test_other_apps_and_missing_outputs_never_enable(self):
        self.assertFalse(self.state.is_gaming({}))
        self.game["app_id"] = "steam"
        self.state.update({"WindowOpenedOrChanged": {"window": self.game}})
        self.assertFalse(self.state.is_gaming(self.outputs))

    def test_opening_focused_game_and_replacing_snapshot(self):
        self.state.update({"WindowsChanged": {"windows": []}})
        self.assertFalse(self.state.is_gaming(self.outputs))
        self.state.update({"WindowOpenedOrChanged": {"window": self.game}})
        self.assertTrue(self.state.is_gaming(self.outputs))
        self.state.update({"WindowsChanged": {"windows": []}})
        self.assertFalse(self.state.is_gaming(self.outputs))

    def test_override_preserves_host_defaults_and_avoids_reload_loop(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "game-mode.kdl"
            helper["write_mode"](True, path)
            self.assertIn('mod-key "Super"', path.read_text())
            stamp = path.stat().st_mtime_ns
            helper["write_mode"](True, path)
            self.assertEqual(path.stat().st_mtime_ns, stamp)
            helper["write_mode"](False, path)
            self.assertNotIn("mod-key", path.read_text())


if __name__ == "__main__":
    unittest.main()
