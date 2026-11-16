#!/usr/bin/env python3
"""Monta as pranchas de conceito (1920 x 1080) a partir da arte real do jogo.
Uso: python3 pranchas.py <pasta do projeto> <pasta das capturas> <saida>
"""
import os, sys, random
from PIL import Image, ImageDraw, ImageFont, ImageFilter, ImageChops

P, CAPT, OUT = sys.argv[1], sys.argv[2], sys.argv[3]
os.makedirs(OUT, exist_ok=True)
A = os.path.join(P, "assets")
W, H = 1920, 1080
VINHO = (104, 22, 22)
TINTA = (52, 36, 26)
SEPIA = (110, 84, 58)
TIT = os.path.join(A, "title_font.ttf")
SERIF = "/usr/share/fonts/truetype/dejavu/DejaVuSerif.ttf"
SERIF_B = "/usr/share/fonts/truetype/dejavu/DejaVuSerif-Bold.ttf"
SERIF_I = "/usr/share/fonts/truetype/dejavu/DejaVuSerif-Italic.ttf"
for cand in (SERIF, SERIF_B, SERIF_I):
    assert os.path.exists(cand), cand
f = lambda path, s: ImageFont.truetype(path, s)


def pergaminho(seed):
    rnd = random.Random(seed)
    base = Image.new("RGB", (W, H), (226, 202, 160))
    ruido = Image.effect_noise((W // 4, H // 4), 34).resize((W, H), Image.BICUBIC).filter(ImageFilter.GaussianBlur(3))
    manchas = Image.effect_noise((W // 40, H // 40), 60).resize((W, H), Image.BICUBIC).filter(ImageFilter.GaussianBlur(40))
    base = ImageChops.multiply(base, Image.merge("RGB", [ruido.point(lambda v: 205 + (v - 128) // 3)] * 3))
    base = ImageChops.multiply(base, Image.merge("RGB", [manchas.point(lambda v: 190 + (v - 128) // 2)] * 3))
    # vinheta escura nas bordas
    vin = Image.new("L", (W, H), 0)
    d = ImageDraw.Draw(vin)
    d.rectangle((70, 60, W - 70, H - 60), fill=255)
    vin = vin.filter(ImageFilter.GaussianBlur(110))
    escuro = Image.new("RGB", (W, H), (58, 36, 24))
    base = Image.composite(base, escuro, vin)
    d = ImageDraw.Draw(base)
    # moldura dupla com cantoneiras
    d.rectangle((26, 26, W - 27, H - 27), outline=(60, 30, 22), width=4)
    d.rectangle((38, 38, W - 39, H - 39), outline=(96, 60, 40), width=1)
    for cx, cy in ((38, 38), (W - 39, 38), (38, H - 39), (W - 39, H - 39)):
        d.regular_polygon((cx, cy, 13), 4, rotation=45, fill=VINHO, outline=(40, 20, 14))
    for _ in range(26):  # respingos de tinta
        x, y, r = rnd.randint(60, W - 60), rnd.randint(60, H - 60), rnd.randint(1, 3)
        d.ellipse((x - r, y - r, x + r, y + r), fill=(90, 60, 40))
    return base


def titulo(img, texto, sub):
    d = ImageDraw.Draw(img)
    fonte = f(TIT, 62)
    while d.textlength(texto, font=fonte) > 1250: fonte = f(TIT, fonte.size - 4)
    w = d.textlength(texto, font=fonte)
    x = (W - w) / 2
    d.text((x + 2, 60), texto, font=fonte, fill=(30, 14, 10))
    d.text((x, 58), texto, font=fonte, fill=VINHO)
    y = 58 + fonte.size // 2 + 6
    for lado in (-1, 1):
        x0 = W / 2 + lado * (w / 2 + 30)
        x1 = W / 2 + lado * (w / 2 + 230)
        d.line((x0, y, x1, y), fill=VINHO, width=2)
        d.regular_polygon((x1, y, 6), 4, rotation=45, fill=VINHO)
        d.regular_polygon((x0, y, 4), 4, rotation=45, fill=VINHO)
    fs = f(SERIF_I, 24)
    d.text(((W - d.textlength(sub, font=fs)) / 2, 134), sub, font=fs, fill=TINTA)


def moldura(img, caixa, rotulo=None):
    d = ImageDraw.Draw(img)
    x0, y0, x1, y1 = caixa
    d.rectangle((x0 - 7, y0 - 7, x1 + 6, y1 + 6), outline=(52, 26, 18), width=3)
    d.rectangle((x0 - 2, y0 - 2, x1 + 1, y1 + 1), outline=(150, 104, 60), width=1)
    if rotulo: etiqueta(img, (x0 + x1) // 2, y1 + 8, rotulo)


def etiqueta(img, cx, y, texto, fundo=VINHO):
    d = ImageDraw.Draw(img)
    fonte = f(SERIF_B, 17)
    w = d.textlength(texto, font=fonte) + 44
    d.rounded_rectangle((cx - w / 2, y, cx + w / 2, y + 32), radius=6, fill=fundo, outline=(40, 16, 12), width=2)
    d.text((cx - w / 2 + 22, y + 5), texto, font=fonte, fill=(236, 220, 190))


def encaixar(im, w, h, foco=(0.5, 0.5)):
    """Corta no formato w:h em torno do foco e redimensiona."""
    im = im.convert("RGB")
    r = w / h
    if im.width / im.height > r:
        nw = int(im.height * r); x = int((im.width - nw) * foco[0]); im = im.crop((x, 0, x + nw, im.height))
    else:
        nh = int(im.width / r); y = int((im.height - nh) * foco[1]); im = im.crop((0, y, im.width, y + nh))
    return im.resize((w, h), Image.LANCZOS)


def paleta(im, n=6):
    q = im.convert("RGB").resize((160, 90)).quantize(n, method=Image.MEDIANCUT).getpalette()[: n * 3]
    cores = [tuple(q[i:i + 3]) for i in range(0, n * 3, 3)]
    return sorted(cores, key=lambda c: c[0] * 0.3 + c[1] * 0.59 + c[2] * 0.11)


def faixa_paleta(img, x, y, cores, lado=44):
    d = ImageDraw.Draw(img)
    d.text((x, y - 26), "PALETA", font=f(SERIF_B, 15), fill=SEPIA)
    for i, c in enumerate(cores):
        d.rectangle((x + i * (lado + 6), y, x + i * (lado + 6) + lado, y + lado), fill=c, outline=(40, 22, 16), width=2)


def paragrafo(img, x, y, largura, texto, fonte, cor=TINTA, entre=8):
    d = ImageDraw.Draw(img)
    linhas, atual = [], ""
    for palavra in texto.split():
        t = (atual + " " + palavra).strip()
        if d.textlength(t, font=fonte) <= largura: atual = t
        else: linhas.append(atual); atual = palavra
    linhas.append(atual)
    for l in linhas:
        d.text((x, y), l, font=fonte, fill=cor); y += fonte.size + entre
    return y


def notas(img, x, y, largura, itens):
    d = ImageDraw.Draw(img)
    for cab, texto in itens:
        d.text((x, y), cab.upper(), font=f(SERIF_B, 17), fill=VINHO)
        d.line((x, y + 25, x + largura, y + 25), fill=(150, 104, 60), width=1)
        y = paragrafo(img, x, y + 33, largura, texto, f(SERIF, 19)) + 14
    return y


def quadro(folha, i, cel=256):
    im = Image.open(os.path.join(A, "animation", folha + ".png")).convert("RGBA")
    col = im.width // cel
    return im.crop(((i % col) * cel, (i // col) * cel, (i % col) * cel + cel, (i // col) * cel + cel))


def figura(img, sprite, caixa, sombra=True):
    """Cola um sprite recortado, de pé no fundo da caixa."""
    bb = sprite.getbbox()
    if bb: sprite = sprite.crop(bb)
    x0, y0, x1, y1 = caixa
    e = min((x1 - x0) / sprite.width, (y1 - y0) / sprite.height)
    s = sprite.resize((max(1, int(sprite.width * e)), max(1, int(sprite.height * e))), Image.LANCZOS)
    px, py = x0 + (x1 - x0 - s.width) // 2, y1 - s.height
    if sombra:
        so = Image.new("RGBA", img.size, (0, 0, 0, 0))
        ImageDraw.Draw(so).ellipse((px + s.width * 0.08, y1 - 14, px + s.width * 0.92, y1 + 16), fill=(40, 22, 14, 150))
        img.paste(Image.alpha_composite(img.convert("RGBA"), so.filter(ImageFilter.GaussianBlur(9))).convert("RGB"))
    img.paste(s, (px, py), s)


def rodape(img, texto):
    d = ImageDraw.Draw(img)
    fonte = f(SERIF_I, 15)
    d.text((W - 70 - d.textlength(texto, font=fonte), 1006), texto, font=fonte, fill=(84, 60, 40))


# ---------------------------------------------------------------- cenários
def prancha_cenario(n, chave, nome, sub, arte, captura, foco, itens):
    img = pergaminho(n)
    titulo(img, nome, sub)
    pint = Image.open(os.path.join(A, arte))
    grande = (70, 190, 70 + 1130, 190 + 560)
    img.paste(encaixar(pint, 1130, 560, foco), grande[:2]); moldura(img, grande, "PINTURA DO CENÁRIO")
    cap = Image.open(os.path.join(CAPT, captura))
    det = (1250, 190, 1250 + 600, 190 + 338)
    img.paste(encaixar(cap, 600, 338), det[:2]); moldura(img, det, "EM JOGO")
    notas(img, 1250, 590, 600, itens)
    # três detalhes ampliados da pintura
    for k, fx in enumerate((0.12, 0.5, 0.88)):
        lado = 280
        cx = int(pint.width * fx); cy = int(pint.height * 0.55); r = int(pint.height * 0.2)
        rec = pint.convert("RGB").crop((max(0, cx - int(r * 1.5)), cy - r, min(pint.width, cx + int(r * 1.5)), cy + r))
        cx0 = 70 + k * (lado + 25)
        caixa = (cx0, 812, cx0 + lado, 812 + 150)
        img.paste(encaixar(rec, lado, 150), caixa[:2]); moldura(img, caixa, "DETALHE " + "I" * (k + 1))
    faixa_paleta(img, 985, 880, paleta(pint), lado=34)
    rodape(img, "Lacrimae of the Penitent · prancha de cenário %02d · arte do jogo" % n)
    img.save(os.path.join(OUT, "cenario-%02d-%s.png" % (n, chave)))


CENARIOS = [
    ("cidade", "CIDADE DA PENITÊNCIA", "Onde o condenado desperta e onde os portões esperam.", "vespera_panorama.png", "sala-city.png", (0.5, 0.5), [
        ("O lugar", "A cripta do túmulo, o pátio de Iria, a ponte quebrada sobre o abismo e os portões do Guardião. É o centro do mapa: todo caminho sai daqui e volta para cá."),
        ("Na história", "Aqui o jogador recolhe a espada, ouve Iria reconhecer a sua voz e, no fim, desce pelos portões."),
        ("Clima", "Pedra fria e céu de chumbo. As velas são a única cor quente."),
    ]),
    ("ossuario", "OSSUÁRIO DOS SEM NOME", "Aqui não se enterravam nomes: enterravam-se números.", "ossuary.png", "sala-ossuary.png", (0.5, 0.5), [
        ("O lugar", "Galerias de nichos e ossos empilhados sob a cidade. Um espaço entre os túmulos continua limpo."),
        ("Na história", "O lugar vazio e o pano escrito \"voltarei amanhã\": a primeira pista de que alguém ficou para trás."),
        ("Quem ronda", "A Viúva da Lâmina: a lanterna dela alerta as criaturas próximas."),
    ]),
    ("cisterna", "CISTERNA DOS NOMES", "A água guarda o que a cidade tentou lavar.", "cistern.png", "sala-cistern.png", (0.5, 0.5), [
        ("O lugar", "Reservatório sob a cidade, de pedra verde e musgo. No alto fica uma das duas correntes dos sinos."),
        ("Na história", "Ao soltar a corrente, a água baixa e descobre a frase \"ainda cabem mais dois\"."),
        ("Quem ronda", "O Meio-Enterrado: a terra se mexe antes do bote."),
    ]),
    ("claustro", "CLAUSTRO DOS VOTOS", "Promessas feitas de joelhos, cobradas de pé.", "cloister.png", "sala-cloister.png", (0.5, 0.5), [
        ("O lugar", "Arcadas de tijolo sob um céu de brasa. Liga a cidade ao Campanário e ao Arquivo."),
        ("Na história", "Passagem obrigatória: é aqui que o combate deixa de ser contra um inimigo só."),
        ("Quem ronda", "Os Dois Velhos: um aponta, o outro arremessa."),
    ]),
    ("campanario", "CAMPANÁRIO DA VIGÍLIA", "Subir para calar o instrumento que cobre as vozes.", "tower.png", "sala-belfry.png", (0.5, 0.4), [
        ("O lugar", "A única sala vertical do jogo: uma torre de escadas e galerias até os sinos."),
        ("Na história", "No fundo está o Espinho da Contrição (salto duplo). No alto, a segunda corrente; ao soltá-la, ouvem-se três batidas."),
        ("Clima", "Vermelho de forja e bronze. Tudo aqui vibra."),
    ]),
    ("arquivo", "ARQUIVO DAS CONFISSÕES", "Uma lista de famílias, sem sentença. Ao lado de cada nome: aguardando.", "gallery.png", "sala-archive.png", (0.5, 0.5), [
        ("O lugar", "Estantes, mesas de escriba e vitrais azuis. O único cenário frio do percurso principal."),
        ("Na história", "O Registro dos que esperaram: Alba, Joana e Tomé. A página seguinte deixa de contar pessoas e passa a pesar lágrimas."),
        ("Quem ronda", "O Sono: dorme sobre os livros e o seu sonho solta um enxame de aves."),
    ]),
    ("abrigo", "ABRIGO DAS CINZAS", "Alguém preparou abrigo para quem nunca chegou.", "gates.png", "sala-refuge.png", (0.5, 0.6), [
        ("O lugar", "Pátio externo com cobertores, fogueiras apagadas e um céu roxo de cinza."),
        ("Na história", "A boneca de pano com um sol bordado no pulso, e o Vaso da Última Vigília, que dá mais um frasco de cura."),
        ("Quem ronda", "O Glutão: come com colheres o que não consegue perdoar."),
    ]),
    ("nave", "NAVE DO SILÊNCIO", "Todos os bancos foram virados para a parede.", "nave_silencio.png", "sala-nave.png", (0.5, 0.5), [
        ("O lugar", "Sala secreta. Uma nave de igreja com velas acesas e nenhum fiel."),
        ("Na história", "O terço de contas apagadas: cada conta foi lixada até perder o nome que levava."),
        ("Quem ronda", "As Parcas: o fio marca onde a tesoura vai cortar."),
    ]),
    ("terraco", "TERRAÇO DOS SINOS", "O sino foi calado por dentro, antes de tocar a última vez.", "terraco_sinos.png", "sala-terrace.png", (0.5, 0.5), [
        ("O lugar", "Sala secreta. Um terraço aberto, de noite azul, com sinos enormes sem badalo."),
        ("Na história", "A corda cortada à faca: alguém não quis que o alarme tocasse."),
        ("Quem ronda", "O Espantalho do Medo: a mortalha esconde pernas de pau."),
    ]),
    ("patio", "PÁTIO DOS PORTÕES SELADOS", "Fechados por fora, com correntes que ninguém forjou aqui.", "patio_portoes.png", "sala-court.png", (0.5, 0.5), [
        ("O lugar", "Sala secreta. O lado de dentro dos portões, com as marcas de quem tentou sair."),
        ("Na história", "O decreto selado em cera: \"quem chorar será contado entre os culpados\". É o gancho para o que vem depois."),
        ("Quem ronda", "A Romaria: uma massa de peregrinos que se protege andando junta."),
    ]),
]


def prancha_vale(n):
    img = pergaminho(n)
    titulo(img, "VALE DOS FLAGELADOS", "Onde a culpa permanece.")
    cam = [Image.open(os.path.join(A, "vale", x)).convert("RGBA") for x in ("ceu.png", "desfiladeiro_longe.png", "desfiladeiro_meio.png", "desfiladeiro_perto.png")]
    comp = Image.new("RGBA", (1440, 720), (20, 10, 14, 255))
    comp.alpha_composite(cam[0].crop((0, 0, 1440, 720)))
    for k, c in enumerate(cam[1:]): comp.alpha_composite(c.crop((300 + k * 180, 0, 1740 + k * 180, 720)))
    forcas = Image.open(os.path.join(A, "vale", "forcas.png")).convert("RGBA")
    comp.alpha_composite(forcas.crop((0, 0, 512, 512)).resize((420, 420)), (140, 250))
    comp.alpha_composite(forcas.crop((512, 0, 1024, 512)).resize((420, 420)), (860, 250))
    grande = (70, 190, 1200, 750)
    img.paste(encaixar(comp, 1130, 560), grande[:2]); moldura(img, grande, "CAMADAS PINTADAS COM PARALAXE")
    det = (1250, 190, 1850, 528)
    img.paste(encaixar(Image.open(os.path.join(CAPT, "sala-vale.png")), 600, 338), det[:2]); moldura(img, det, "EM JOGO")
    notas(img, 1250, 590, 600, [
        ("O lugar", "Além dos portões. Forcas, gaiolas penduradas, árvores mortas e névoa. O céu escurece a cada placa de armadura que cai."),
        ("Na história", "Tudo o que o ritual tirou das pessoas, e tudo o que o Penitente pediu para esquecer, ficou aqui. É onde a jornada termina."),
        ("Quem espera", "Os Disciplinantes, em fila atrás do escudo, e O Flagelado, de joelhos entre as forcas."),
    ])
    for k, (arq, rot, cx) in enumerate((("ceu.png", "CÉU", 0.3), ("desfiladeiro_longe.png", "FUNDO", 0.3), ("desfiladeiro_perto.png", "FRENTE", 0.4))):
        c = Image.open(os.path.join(A, "vale", arq)).convert("RGBA")
        fundo = Image.new("RGBA", c.size, (38, 24, 26, 255)); fundo.alpha_composite(c)
        cx0 = 70 + k * 305
        caixa = (cx0, 812, cx0 + 280, 962)
        img.paste(encaixar(fundo, 280, 150, (cx, 0.5)), caixa[:2]); moldura(img, caixa, "CAMADA: " + rot)
    faixa_paleta(img, 985, 880, paleta(comp), lado=34)
    rodape(img, "Lacrimae of the Penitent · prancha de cenário %02d · arte do jogo" % n)
    img.save(os.path.join(OUT, "cenario-%02d-vale.png" % n))


# ---------------------------------------------------------------- personagens e criaturas
def prancha_figura(arquivo, nome, sub, principal, detalhe, rot_detalhe, poses, itens, seed, cel=256, rodape_txt="prancha de personagem"):
    img = pergaminho(seed)
    titulo(img, nome, sub)
    figura(img, principal, (90, 200, 640, 960))
    if detalhe is not None:
        det = (700, 200, 700 + 420, 200 + 420)
        img.paste(encaixar(detalhe, 420, 420), det[:2]); moldura(img, det, rot_detalhe)
        tx, larg = 1180, 660
    else:
        tx, larg = 720, 1120
    notas(img, tx, 200, larg, itens)
    # poses
    n = len(poses)
    larg_p = 250
    x0 = 700 + (1150 - n * larg_p - (n - 1) * 30) // 2
    d = ImageDraw.Draw(img)
    for k, (spr, rot) in enumerate(poses):
        cx = x0 + k * (larg_p + 30)
        d.line((cx + 20, 905, cx + larg_p - 20, 905), fill=(120, 84, 54), width=2)
        figura(img, spr, (cx, 690, cx + larg_p, 905), sombra=False)
        etiqueta(img, cx + larg_p // 2, 918, rot)
    px = [c[:3] for c in principal.getdata() if c[3] > 200]
    tira = Image.new("RGB", (len(px), 1)); tira.putdata(px)
    q = tira.quantize(6, method=Image.MEDIANCUT).getpalette()[:18]
    cores = sorted([tuple(q[i:i + 3]) for i in range(0, 18, 3)], key=sum)
    faixa_paleta(img, 90, 1000 - 20, cores, lado=36)
    rodape(img, "Lacrimae of the Penitent · %s · arte do jogo" % rodape_txt)
    img.save(os.path.join(OUT, arquivo))


def close(nome):
    return Image.open(os.path.join(A, "close", nome))


def gerar_personagens():
    q = quadro
    prancha_figura("personagem-01-penitente.png", "O PENITENTE", "Aquele que condenou milhares deverá carregar o peso de cada lágrima.",
        q("hero_combate", 20), close("close_01_mascarado.png"), "DETALHE: O CAPIROTE",
        [(q("hero_motion", 0), "EM GUARDA"), (q("hero_combat", 2), "GOLPE"), (q("hero_combate", 2), "APARO"), (q("hero_combat", 20), "ORAÇÃO")], [
        ("Quem é", "Guerreiro sem memória, condenado a não descansar na morte. Desperta num túmulo com uma inscrição que o acusa. Chora sangue sem saber por quê."),
        ("Aparência", "Armadura de bronze escurecido, capa vermelha em tiras, capirote de ferro com coroa de espinhos. O rosto nunca aparece, exceto uma vez, no fim."),
        ("Como joga", "Espada: combo de três golpes, golpe carregado, golpe descendente, aparo com contra-ataque, esquiva e execuções."),
        ("O que esconde", "De si mesmo: de quem eram as mãos que fecharam os portões."),
    ], 101)
    prancha_figura("personagem-02-beatriz.png", "BEATRIZ", "Nunca olhou o rosto de quem feriu.",
        q("beatriz_combate", 2), close("close_beatriz.png"), "DETALHE: A MÁSCARA",
        [(q("beatriz_movimento", 0), "EM GUARDA"), (q("beatriz_combate", 8), "VARREDURA"), (q("beatriz_reacoes", 1), "APARO"), (q("beatriz_peso", 2), "A LANÇA PESA")], [
        ("Quem é", "Segunda personagem jogável. Foi a mão armada da Inquisição: executava sob ordens cegas. Hoje caminha ao lado do Penitente."),
        ("Aparência", "Máscara de ferro lisa, sem aberturas para os olhos; capuz e armadura de carrasca; mãos enfaixadas. Carrega a Lança de Vladimir, com relíquias amarradas à haste."),
        ("Como joga", "Alcance longo: estocada, varredura e empalamento. Luta sozinha ou nas mãos de um segundo jogador. Os dois dividem o sangue: um pode levantar o outro."),
        ("O arco", "A lança pesa mais a cada morte. No fim, é ela quem escolhe olhar."),
    ], 102)
    prancha_figura("personagem-03-iria.png", "IRIA", "Condenado... eu reconheceria sua voz.",
        q("iria", 0), None, "",
        [(q("iria", 0), "PARADA"), (q("iria", 7), "FALANDO"), (q("iria", 13), "ANDANDO"), (q("iria", 19), "REZANDO")], [
        ("Quem é", "Sobrevivente da Cidade da Penitência. Cega, separa cera de velas no pátio. Reconhece o Penitente pela voz e sabe mais do que diz."),
        ("Aparência", "Cabelos brancos longos, manto claro em tiras, um cajado com um incensário. É a única figura clara num mundo escuro."),
        ("Na história", "Pede que os nomes dos que ficaram sejam lidos em voz alta, e avisa: \"não confunda esse gesto com perdão\"."),
    ], 103)
    prancha_figura("personagem-04-guardiao.png", "O GUARDIÃO DOS SINOS", "Enquanto tocar, alguém virá abrir.",
        q("guardiao_colosso", 0, 512), Image.open(os.path.join(A, "boss", "guardiao_rosto.png")), "DETALHE: BRONZE E CARNE",
        [(q("guardiao_colosso_ataques", 1, 512), "VARREDURA"), (q("guardiao_colosso_ataques", 5, 512), "SALTO"), (q("guardiao_colosso_ataques", 9, 512), "GRITO"), (q("guardiao_colosso_ataques", 13, 512), "EXAUSTO")], [
        ("Quem é", "Primeiro chefe. Um homem fundido ao sino que tocava, puxando uma corda que já não existe. Toca o alarme para não ter de ouvir a cidade."),
        ("Aparência", "Um colosso de bronze: o sino virou cabeça e ombros, a capa vermelha virou pele. Sinos menores pendem do corpo."),
        ("A luta", "Cada ataque tem um aviso no corpo: braço recuado é varredura, agachar é salto, sino erguido é grito. Fica exausto e se ajoelha: é a hora de ferir."),
        ("Última fala", "\"Não veio ninguém.\""),
    ], 104, cel=512)
    estados = [q("flagelado_estados", i) for i in (0, 6, 12, 18)]
    prancha_figura("personagem-05-flagelado.png", "O FLAGELADO", "Alguém espera entre as forcas, coberto de ferro e dos pecados de outros.",
        q("flagelado_movimento", 0), close("close_flagelado_elmo.png"), "DETALHE: O ELMO-GAIOLA",
        [(estados[0], "1 · A DESCULPA"), (estados[1], "2 · O ESQUECIMENTO"), (estados[2], "3 · O CASTIGO"), (estados[3], "4 · A QUEDA")], [
        ("Quem é", "Chefe final, no Vale. Um estranho de ferro, curvado, maior que o Penitente. O que há sob o elmo só a última cena mostra."),
        ("Aparência", "Elmo de sino com grade de confessionário e cadeado no queixo; pergaminhos de pecados pregados à armadura; velas derretidas nos ombros. A arma é a tranca dos portões."),
        ("A luta", "Ele veste a forma de quem o ataca: enquanto vestir, ferir é ferir-se. Aparar ou deixá-lo rezar arranca o reflexo."),
        ("As quatro placas", "A armadura cai em quatro partes, cada uma com o nome de um modo de fugir da culpa. Ele não morre: ajoelha."),
    ], 105)


CRIATURAS = [
    ("devoto", "devotee", "O DEVOTO", "Reza com a boca e fere com as mãos.", "O inimigo comum da cidade: um fiel que o Grande Pranto deformou. Anda devagar e bate com o incensário.", "Ensina o básico: ler o aviso, esquivar, responder."),
    ("carpideira", "mourner", "A CARPIDEIRA", "Chora por todos, menos por si.", "Espectro pálido de mantos em tiras. Flutua e ataca à distância.", "Obriga a encurtar a distância em vez de esperar."),
    ("devorador", "devorador", "O DEVORADOR", "O que ele não consegue perdoar, ele engole.", "Um corpo enorme e curvo, boca aberta. Vem do Saturno das Pinturas Negras de Goya.", "Dá o bote e fica aberto: esquive e golpeie na recuperação."),
    ("flagelante", "flagelante", "O FLAGELANTE", "Pune o corpo para calar o que a alma sabe.", "Penitente de capirote e torso nu, com o açoite na mão. Vem das procissões de Goya.", "Investe em linha reta: faça-o errar."),
    ("duelistas", "duelista", "OS DUELISTAS", "Lutam até os joelhos no mesmo chão.", "Dois homens de porrete, presos numa briga que não acaba. Vem do Duelo a Garrotazos.", "Ignoram quem não os atrapalha; atravessar é uma escolha."),
    ("aquelarre", "bruxa", "O AQUELARRE", "Três vozes, um voto.", "Três irmãs de mantos verdes em farrapos. Vem do Aquelarre de Goya.", "Enquanto uma vive, amortece o golpe nas outras: é preciso escolher a ordem."),
    ("asmodeia", "asmodeia", "ASMODEIA", "Paira sobre o povo e deixa cair a sentença.", "Figura encapuzada de manto vermelho e máscara de osso. Vem da Visão Fantástica de Goya.", "Ataca de cima: não fique sob ela."),
    ("carregador", "carregador", "O CARREGADOR DE CAIXÃO", "Carrega a própria sepultura.", "Um homem vendado com um caixão de pedra amarrado às costas.", "A pedra protege a frente: faça-o errar a investida e golpeie pelas costas."),
]


def gerar_criaturas():
    for k, (chave, ator, nome, sub, desc, luta) in enumerate(CRIATURAS):
        folha = ator
        poses = [(quadro(folha, 0), "PARADO"), (quadro(folha, 8), "ANDANDO"), (quadro(folha, 14), "ATAQUE"), (quadro("reacoes_" + {"devotee": "devoto", "mourner": "choro"}.get(ator, ator), 14), "ABERTURA")]
        prancha_figura("criatura-%02d-%s.png" % (k + 1, chave), nome, sub, quadro(folha, 0), None, "", poses, [
            ("O que é", desc),
            ("No combate", luta),
            ("O ciclo", "Toda criatura segue o mesmo desenho: aviso, ataque e abertura. A abertura é a hora de ferir; quem cambaleia pode ser executado."),
        ], 200 + k, rodape_txt="prancha de criatura")


if __name__ == "__main__":
    for i, c in enumerate(CENARIOS): prancha_cenario(i + 1, *c)
    prancha_vale(len(CENARIOS) + 1)
    gerar_personagens()
    gerar_criaturas()
    print(len(os.listdir(OUT)), "pranchas")
