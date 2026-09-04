# 🌿 Aplua

> **Uma engine de jogos 2D minimalista baseada em Nós (Nodes), escrita em Lua e inspirada na hierarquia e simplicidade da Godot.**

---

## 🎯 Visão do Projeto

O **Aplua** nasce com o objetivo de unir a leveza e dinamismo do **Lua** à elegância arquitetural da **Godot**. 

Em vez de lidar com loops manuais e renderização de baixo nível, o desenvolvedor estrutura seu jogo como uma **Árvore de Nós** (*Scene Tree*). Futuramente, o projeto pretende evoluir para incluir ferramentas visuais como **Editor de Cenas (Drag & Drop)** e inspetor de propriedades.

---

## 🏛️ Arquitetura

Para manter o desenvolvimento ágil, moderno e sem a sobrecarga de gerenciar drivers de vídeo em C/C++, a engine adota uma divisão clara de responsabilidades:

* **Runtime de Baixo Nível (LÖVE2D):** Gerencia a criação da janela, contexto gráfico OpenGL, áudio e captura de eventos de teclado/mouse.
* **Aplua Framework (O Cérebro da Engine):** Camada de alto nível que implementa:
  * Sistema de Nós e hierarquia pai/filho.
  * Ciclo de vida dos objetos (`_ready`, `_process`, `_draw`).
  * Herança de transformação espacial 2D (coordenadas locais vs globais).
  * Nós especializados (`AnimatedSprite2D`, `Camera2D`, etc.).
  * Sistema de Sinais (*Signals/Events*).
  * Gerenciamento de Cenas e Recursos.

---

## 🌳 O Sistema de Nós (*Scene Tree*)

Na Aplua, **tudo no jogo é um Nó (`Node`)**. 

```text
CenaRaiz (Scene)
 └── Player (Node2D, posição: 100, 100)
      ├── Sprite (AnimatedSprite2D)
      ├── Camera (Camera2D)
      └── Arma (Node2D, posição relativa: 15, 0)
           └── PontaDoCano (pos relativa: 10, 0)
```

### Ciclo de Vida:
* **`_ready()`:** Executado uma única vez quando o nó entra na árvore.
* **`_process(dt)`:** Executado a cada frame para lógica e física (`dt` = delta time).
* **`_draw()`:** Executado a cada frame para renderizar gráficos na tela.

---

## 💻 Exemplo de Código Alvo

A ideia é que programar na Aplua seja tão simples e intuitivo quanto na Godot:

```lua
local Node2D = require("aplua.nodes.node_2d")
local AnimatedSprite2D = require("aplua.nodes.animated_sprite_2d")

local Player = setmetatable({}, { __index = Node2D })
Player.__index = Player

function Player.new()
    local self = setmetatable(Node2D.new("Player"), Player)
    
    -- Criação de um sprite animado com folha de sprites
    self.sprite = AnimatedSprite2D.new("assets/player_sheet.png", 32, 32)
    self.sprite:add_animation("run", {1, 2, 3, 4}, 0.1, true)
    self.sprite:play("run")
    
    self:add_child(self.sprite)
    return self
end

function Player:_process(dt)
    if aplua.input.is_down("right") then
        self.x = self.x + 150 * dt
    end
end

return Player
```

---

## 📁 Estrutura Planejada

```text
aplua/
├── .devcontainer/                # Ambiente Plug & Play (Codespaces com Desktop Web)
│   └── devcontainer.json
│
├── aplua/                        # 🌿 CÓDIGO DA ENGINE
│   ├── init.lua                  # Ponto de entrada da engine
│   ├── core/                     # Núcleo essencial
│   │   ├── object.lua            # Herança e classes em Lua
│   │   ├── node.lua              # O Nó base (hierarquia e ciclo de vida)
│   │   ├── node_2d.lua           # Nó espacial com posição, rotação e escala
│   │   └── scene_tree.lua        # Gerenciador da árvore de cenas e Game Loop
│   ├── nodes/                    # Nós visuais e de utilidade
│   │   ├── sprite_2d.lua         # Sprites estáticos
│   │   ├── animated_sprite_2d.lua# Animação por SpriteSheet
│   │   └── camera_2d.lua         # Câmera 2D com zoom e interpolação (lerp)
│   └── math/                     # Utilitários matemáticos
│       └── vector2.lua           # Vetores 2D e transformações
│
├── sandbox/                      # 🎮 AMBIENTE DE TESTE / JOGO EXEMPLO
│   ├── assets/                   # Texturas, fontes e sons
│   └── scenes/                   # Cenas de teste
│       └── main_scene.lua
│
├── conf.lua                      # Configurações de janela do LÖVE
├── main.lua                      # Bootstrap que liga o LÖVE à Aplua
└── README.md
```

---

## 🗺️ Roteiro de Desenvolvimento (Roadmap)

- [x] **Fase 0: Concepção e Arquitetura**
  - Definição do escopo, filosofia e design de nós.
- [ ] **Fase 1: Ambiente e Núcleo (Core)**
  - Configuração do Dev Container (LÖVE2D + Desktop Web no Codespaces).
  - Implementação da classe `Object` e metatabelas.
  - Implementação de `Node` (árvore, hierarquia, ciclo de vida).
  - Implementação de `Node2D` (transformações globais relativas).
  - `SceneTree` e integração com o loop principal (`love.update`, `love.draw`).
- [ ] **Fase 2: Gráficos e Mídia**
  - Implementação de `Sprite2D` e gerenciador de texturas.
  - Implementação de `AnimatedSprite2D` (corte automático de folhas de sprites).
  - Implementação de `Camera2D` (seguimento suave e zoom).
- [ ] **Fase 3: Entradas e Comunicação**
  - Sistema de `Input` simplificado (`is_action_just_pressed`).
  - Sistema de Sinais (*Signals* / Eventos desacoplados).
- [ ] **Fase 4: Serialização de Cenas**
  - Formato de arquivo de cena (`.scene` em Lua/JSON).
  - Carregador dinâmico de cenas.
- [ ] **Fase 5: Ferramentas e Editor Visual**
  - Interface do editor (Canvas 2D interativo).
  - Sistema de arrastar e soltar (Drag & Drop) de nós na cena.
  - Painel de propriedades (Inspetor).