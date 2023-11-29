import argparse
import difflib
import json
import os
import sys
from collections import defaultdict
from io import TextIOBase
from pathlib import Path
from typing import Any, Callable, DefaultDict, Dict, List, Tuple, Union

HOME: Path = Path.home()
ALIAS_CACHE: str = f"{HOME}/.alias_cache/.alias_cache"

CONFIG = os.environ["CONFIG"]


def manage_error():
    def decorator(func):
        def wrapper(*args, **kwargs):
            try:
                func(*args, **kwargs)
            except KeyError:
                option = func.__name__.replace("show_", "")
                close_matches = difflib.get_close_matches(
                    kwargs["name"],
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


class SaveAlias:
    categories: DefaultDict = defaultdict(list)
    alias: DefaultDict = defaultdict(dict)

    @classmethod
    def write(cls, data: Dict[str, Dict]) -> None:
        with open(ALIAS_CACHE, "w+") as w:
            json.dump(data, w)
        return None

    def get_category_name(self, line: str) -> None:
        self.category_name = line.replace("#C# ", "").replace("\n", "")
        return None

    def add_alias_to_category(self, line: str) -> None:
        self.save_action_and_name(line)
        self.categories[self.category_name].append(self.alias_name)
        return None

    def split_get_alias_name_and_action(self, line: str) -> Tuple[str, str]:
        splited_alias = line.split("=")
        alias_name = splited_alias[0].replace("alias ", "")
        alias_action = splited_alias[1][1:-2]
        return alias_name, alias_action

    def add_action_to_alias(self, alias_name: str, alias_action: str) -> None:
        self.alias[alias_name] = {"action": alias_action}
        return None

    def save_action_and_name(self, line: str) -> None:
        alias_name, alias_action = self.split_get_alias_name_and_action(line)
        self.add_action_to_alias(alias_name, alias_action)
        self.alias_name = alias_name
        return None

    def get_alias_description(self, line: str) -> str:
        return line.replace("#D# ", "").replace("\n", "")

    def add_description_to_alias(
        self,
        alias_name: str,
        alias_description: str,
    ) -> None:
        self.alias[alias_name].update({"description": alias_description})
        return None

    def save_description(self, line: str) -> None:
        description = self.get_alias_description(line)
        self.add_description_to_alias(self.alias_name, description)
        return None

    def return_cache_dict(self) -> Dict:
        return {"categories": self.categories, "alias": self.alias}

    def parse(self, alias_lines: TextIOBase) -> Dict[str, Dict]:
        for line in alias_lines:
            if line.startswith("#C#"):
                self.get_category_name(line)
            elif line.startswith("alias"):
                self.add_alias_to_category(line)
            elif line.startswith("#D#"):
                self.save_description(line)
        return self.return_cache_dict()

    @classmethod
    def save_alias(cls) -> None:
        os.makedirs(os.path.dirname(ALIAS_CACHE), exist_ok=True)
        with open(f"{CONFIG}/.bash_alias", "r") as r:
            alias_dict = cls().parse(r)
        cls.write(alias_dict)
        return None


class ShowAlias:
    @classmethod
    def create_cache(cls) -> None:
        os.makedirs(os.path.dirname(ALIAS_CACHE), exist_ok=True)
        SaveAlias.save_alias()

    @classmethod
    def read_as_json(
        cls,
    ) -> Dict[str, Dict[str, Union[Dict[str, str], List[str]]]]:
        try:
            with open(ALIAS_CACHE, "r") as r:
                return json.load(r)
        except FileNotFoundError:
            cls.create_cache()
            return cls.read_as_json()

    @staticmethod
    def show(to_show: Union[str, Any]) -> None:
        if type(to_show) == str:
            print(to_show)
        else:
            print("\n".join(to_show))
        sys.exit()

    @classmethod
    @manage_error()
    def show_category(
        cls,
        info_retrieved: Dict[str, List[str]],
        name: str,
        alias_file,
    ) -> None:
        name = name.capitalize() if name else ""
        if name:
            info_to_show = []
            for alias_name in info_retrieved[name]:
                alias = alias_file["alias"][alias_name]
                alias_info = cls.prepare_alias_to_show(alias_name, alias)
                info_to_show.append(alias_info)
        else:
            info_to_show = list(info_retrieved.keys())
        return cls.show(info_to_show)

    @classmethod
    def prepare_alias_to_show(cls, name: str, alias: Dict[str, str]) -> str:
        description = alias.get("description", "***************************")
        action = alias["action"]
        return f"{name} -> {action}\n{description}\n"

    @classmethod
    @manage_error()
    def show_alias(
        cls,
        info_retrieved: Dict[str, Dict[str, str]],
        name: str,
        alias_file,
    ) -> None:
        if name:
            alias = info_retrieved[name]
            alias_info = cls.prepare_alias_to_show(name, alias)
            return cls.show(alias_info)
        return cls.show(info_retrieved.keys())

    @classmethod
    @manage_error()
    def show_function(
        cls,
        info_retrieved: Dict[str, List[str]],
        name: str,
        alias_file,
    ) -> None:
        return cls.show(info_retrieved[name])


def prepare_command(
    option: str,
    name: str = "",
) -> None:
    options_map: Dict[str, Callable] = {
        "alias": ShowAlias.show_alias,
        "categories": ShowAlias.show_category,
        "functions": ShowAlias.show_function,
    }
    if option not in options_map:
        SaveAlias.save_alias()
        return None
    alias_file = ShowAlias.read_as_json()
    info_retrieved = alias_file[option]
    return options_map[option](
        info_retrieved=info_retrieved,
        name=name,
        alias_file=alias_file,
    )


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "option",
        type=str,
        choices=[
            "alias",
            "categories",
            "functions",
            "update",
        ],
    )
    parser.add_argument("name", type=str, nargs="?", default="")
    args_dict = vars(parser.parse_args())
    prepare_command(args_dict["option"], args_dict["name"])
