"""Relatório da telemetria local do Lacrimae (user://telemetria.json).

Uso:
    python tools/relatorio_telemetria.py              # arquivo padrão do Windows
    python tools/relatorio_telemetria.py caminho.json # outro arquivo (ex.: de vários playtesters)
    python tools/relatorio_telemetria.py a.json b.json c.json   # soma vários jogadores

Sem dependências externas. Mostra onde os jogadores mais morrem, onde passam mais tempo
e quais dúvidas mais levam ao Confessor, os dados que orientam ajustes de dificuldade.
"""
import json
import os
import sys
from collections import Counter

ROOMS = {
    "city": "Cidade da Penitência", "ossuary": "Ossuário dos Sem Nome", "cistern": "Cisterna dos Nomes",
    "cloister": "Claustro dos Votos", "belfry": "Campanário da Vigília", "archive": "Arquivo das Confissões",
    "refuge": "Abrigo das Cinzas", "nave": "Nave do Silêncio", "terrace": "Terraço dos Sinos",
    "court": "Pátio dos Portões Selados",
}


def default_path() -> str:
    base = os.environ.get("APPDATA", os.path.expanduser("~/.local/share"))
    return os.path.join(base, "Godot", "app_userdata", "Lacrimae of the Penitent", "telemetria.json")


def bar(value: float, top: float, width: int = 28) -> str:
    return "#" * max(1, round(width * value / top)) if top > 0 and value > 0 else ""


def table(title: str, counts: Counter, unit: str = "", names: dict | None = None) -> None:
    print(f"\n{title}")
    if not counts:
        print("  (sem dados ainda)")
        return
    top = max(counts.values())
    for key, value in counts.most_common():
        label = (names or {}).get(key, key)
        shown = f"{value / 60:.1f} min" if unit == "min" else f"{int(value)}"
        print(f"  {label:<28} {shown:>9}  {bar(value, top)}")


def main() -> None:
    paths = sys.argv[1:] or [default_path()]
    deaths, seconds, topics, sources = Counter(), Counter(), Counter(), Counter()
    sessions = questions = 0
    for path in paths:
        if not os.path.exists(path):
            print(f"Arquivo não encontrado: {path}")
            continue
        with open(path, encoding="utf-8") as f:
            data = json.load(f)
        sessions += int(data.get("sessions", 0))
        questions += int(data.get("questions", 0))
        deaths.update({k: float(v) for k, v in data.get("deaths_by_room", {}).items()})
        seconds.update({k: float(v) for k, v in data.get("seconds_by_room", {}).items()})
        topics.update({k: float(v) for k, v in data.get("questions_by_topic", {}).items()})
        sources.update({k: float(v) for k, v in data.get("answers_by_source", {}).items()})
    print(f"LACRIMAE · TELEMETRIA  ({len(paths)} arquivo(s), {sessions} sessões, {questions} perguntas ao Confessor)")
    table("Mortes por lugar", deaths, names=ROOMS)
    table("Tempo por lugar", seconds, unit="min", names=ROOMS)
    table("Dúvidas levadas ao Confessor", topics)
    table("Quem respondeu", sources, names={"gemini": "Gemini (IA)", "offline": "Falas prontas (offline)"})


if __name__ == "__main__":
    main()
