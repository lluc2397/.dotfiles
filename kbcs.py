import argparse
import difflib
import json
import os
import subprocess
import sys
from collections import defaultdict
from pathlib import Path
from typing import Any, DefaultDict, Union

HOME: Path = Path.home()
ALIAS_CACHE: str = f"{HOME}/.alias_cache/.alias_cache"

CONFIG = os.environ["CONFIG"]
TMUX = "tmux"
NEOVIM = "neovim"
LOCAL = "local"
OPTIONS = [
    "",
    TMUX,
    NEOVIM,
    LOCAL,
    "alias",
    "categories",
    "functions",
]
ACTIONS = [
    "refresh",
    "read",
    "create",
    "delete",
    "update",
]


class TerminalColor:
    HEADER = "\033[95m"
    OKBLUE = "\033[94m"
    OKCYAN = "\033[96m"
    OKGREEN = "\033[92m"
    WARNING = "\033[93m"
    FAIL = "\033[91m"
    ENDC = "\033[0m"
    BOLD = "\033[1m"
    UNDERLINE = "\033[4m"


def manage_error():
    def decorator(func):
        def wrapper(*args, **kwargs):
            try:
                func(*args, **kwargs)
            except KeyError:
                option = func.__name__.replace("show_", "")
                close_matches = difflib.get_close_matches(
                    kwargs["search"],
                    kwargs["info_retrieved"].keys(),
                    n=3,
                    cutoff=0.5,
                )
                close_matches_str = " or ".join(close_matches)
                error_message = (
                    f"This {option} doesn't exist, "
                    f"did you mean: {close_matches_str}?"
                )
                if len(close_matches) == 1:
                    input_value = input(
                        f"{error_message} y) Yes | n) No ",
                    )
                    if input_value == "y":
                        kwargs["name"] = close_matches[0]
                        return func(*args, **kwargs)
                else:
                    print(error_message)
                sys.exit()

        return wrapper

    return decorator


class BaseCLI:
    cache_file: str = ""
    categories: DefaultDict = defaultdict(list)
    action: DefaultDict = defaultdict(dict)

    def save(self) -> None:
        os.makedirs(os.path.dirname(self.cache_file), exist_ok=True)
        self.write(self.parse())
        return None

    def parse(self) -> DefaultDict[str, dict]:
        return defaultdict()

    def write(self, data: dict[str, dict]) -> None:
        with open(self.cache_file, "w+") as w:
            json.dump(data, w)
        return None

    def get_json(self) -> dict[str, dict[str, Union[dict[str, str], list[str]]]]:
        try:
            with open(self.cache_file, "r") as r:
                return json.load(r)
        except FileNotFoundError:
            self.save()
            return self.get_json()

    def refresh(self, **kwargs) -> None:
        self.save()

    def read(self, option: str, search: str, **kwargs) -> None:
        try:
            self.show(self.get_json()[option], search)
        except KeyError:
            self.exit_with_message("You should pass an option now")

    def create(self, **kwargs) -> None:
        pass

    def update(self, **kwargs) -> None:
        pass

    def delete(self, **kwargs) -> None:
        pass

    @manage_error()
    def show(self, *args, **kwargs) -> None:
        return None

    @staticmethod
    def _show(to_show: Union[str, Any]) -> None:
        if isinstance(to_show, str):
            print(to_show)
        else:
            print("\n".join(to_show))
        return None

    @staticmethod
    def exit_with_message(msg: str) -> None:
        print(
            subprocess.check_output("tput setaf 1".split()).decode("latin1"),
            msg,
        )
        sys.exit()


class Keybindigs(BaseCLI):
    cache_file: str = f'{os.environ["DOTS"]}/.kb_cache'

    def parse(self) -> DefaultDict[str, dict]:
        result: DefaultDict = defaultdict(dict)
        for k_f, n in [("keys", TMUX), ("vim_k", NEOVIM)]:
            with open(k_f, "r") as f:
                for line in f.readlines():
                    key, desc = line.split(" => ")
                    result[n][desc.strip()] = {
                        "kb": key.strip(),
                        "description": desc.strip(),
                        "extra": "",
                    }
        return result

    @manage_error()
    def show(
        self,
        info_retrieved: dict[str, Any],
        search: str,
    ) -> None:
        if possibilities := self.get_possibilities(search, list(info_retrieved.keys())):
            result = "\n".join(self.prepare_message(info_retrieved, possibilities))
            search_msg = (
                f"{TerminalColor.OKGREEN}Your search: {search} {TerminalColor.ENDC}"
            )
            return self._show(f"{search_msg}\n\n{result}")
        self.exit_with_message("Nothing found")

    def get_possibilities(self, search: str, options: list[str]) -> list[str]:
        return difflib.get_close_matches(search, options) if search else options

    def prepare_message(
        self,
        info_retrieved: dict[str, Any],
        possibilities: list[str],
    ) -> list[str]:
        return [
            self.prepare_action_to_show(**info_retrieved[possibility])
            for possibility in possibilities
        ]

    def prepare_action_to_show(
        self,
        kb: str,
        description: str,
        extra: str,
    ) -> str:
        mode = f"\nmode: {extra}" if extra else ""
        stars = "*" * 50
        return f"Keybindig -> {kb}{mode}\nDescription: {description}\n{stars}\n"


def prepare_command(action: str, platform: str, **kwargs) -> None:
    manager = Keybindigs() if platform == "kb" else "Alias"
    return getattr(manager, action)(**kwargs)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-a",
        "--action",
        type=str,
        choices=ACTIONS,
        required=True,
    )
    parser.add_argument(
        "-p",
        "--platform",
        type=str,
        choices=["kb", "alias"],
        required=True,
    )
    parser.add_argument(
        "-o",
        "--option",
        type=str,
        nargs="?",
        default="",
        choices=OPTIONS,
    )
    parser.add_argument("-search", "--search", type=str, nargs="?", default="")
    parser.add_argument("-e", "--extras", type=str, nargs="?", default="")
    prepare_command(**vars(parser.parse_args()))
