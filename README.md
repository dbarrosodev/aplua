# 🌿 Aplua Engine

Uma engine 2D ágil e moderna em Lua construída sobre o **LÖVE2D**, unindo a **elegância composicional da Godot** à **velocidade de prototipagem do GameMaker**.

---

## 🎯 Visão do Projeto

O desenvolvimento de jogos 2D muitas vezes oscila entre dois extremos:
1. **Engines orientadas a nós rígidos**, onde até as tarefas mais simples exigem nós filhos dedicados e boilerplate de classes.
2. **Frameworks soltos**, onde o desenvolvedor precisa recriar loops de jogo, câmeras, ordenação de profundidade e transformações espaciais do zero.

O **Aplua** resolve isso com uma **arquitetura híbrida**:
* **A Estrutura da Godot:** Uma Árvore de Cenas (Scene Tree) onde nós herdam posição, rotação e escala de seus nós pais, com suporte a sinais desacoplados e cenas reutilizáveis.
* **A Praticidade do GameMaker:** Ciclos de vida com renderização de HUD separada (`_draw` vs `_draw_gui`), variáveis de cinemática rápida (`speed`, `direction`, `friction`), sistema embutido de **Alarmes** e nós com persistência entre transições de telas (`persistent = true`).

---

## 🏛️ Arquitetura do Sistema

```text
┌────────────────────────────────────────────────────────┐
│                   Aplua Framework                      │
│                                                        │
│  [Scene Tree & Hierarquia]     [Atores & Entidades]    │
│  • Transformações Pai/Filho    • Cinemática (hspeed)   │
│  • Sinais (Event-Driven)       • Sistema de Alarmes    │
│  • Z-Ordering / Camadas        • Instâncias Persistentes│
│                                                        │
│  [Pipeline Gráfico Híbrido]    [Gerenciamento Cenas]   │
│  • Camera2D (World Space)      • Cenas como "Rooms"    │
│  • _draw() vs _draw_gui()      • Transição e Cache     │
└───────────────────────────┬────────────────────────────┘
                            │
┌───────────────────────────▼────────────────────────────┐
│               Runtime de Baixo Nível (LÖVE2D)          │
│  Janela, Contexto OpenGL, Áudio, I/O e Loop Principal  │
└────────────────────────────────────────────────────────┘

```

---

## 🌳 O Sistema de Nós (Scene Tree Híbrida)

Na Aplua, qualquer elemento da cena é derivado de `Node`. Nós espaciais derivam de `Node2D`, e entidades dinâmicas utilizam a classe especializada `Actor2D` (uma fusão do *Object* do GameMaker com a hierarquia da Godot):

```text
Room_Fase1 (Scene / Node2D)
 ├── Background (TileLayer / Sprite2D)
 ├── Player (Actor2D) ── [Tem speed, alarmes e colisão nativos]
 │    ├── Gun (Node2D, posição relativa: 12, 4)
 │    │    └── Muzzle (Node2D, pos relativa: 8, 0)
 │    └── Camera (Camera2D) ── [Segue o jogador automaticamente]
 └── Inimigo (Actor2D)

```

### Ciclo de Vida dos Objetos

* `_ready()`: Executado uma única vez quando o nó entra na árvore ativa (*Create Event*).
* `_process(dt)`: Executado a cada frame para lógica e cinemática (*Step Event*).
* `_draw()`: Renderizado no espaço de mundo, afetado pela `Camera2D` (*Draw Event*).
* `_draw_gui()`: Renderizado diretamente na tela/viewport fixa para HUD/UI (*Draw GUI Event*).
* `_alarm(id)`: Disparado quando um temporizador interno do objeto expira (*Alarm Event*).
* `_destroy()`: Executado ao remover o nó da cena (*Destroy / CleanUp Event*).

---

## 💻 Exemplo de Código Alvo

```lua
local Actor2D = require("aplua.nodes.actor_2d")
local AnimatedSprite2D = require("aplua.nodes.animated_sprite_2d")

local Player = setmetatable({}, { __index = Actor2D })
Player.__index = Player

function Player.new()
    local self = setmetatable(Actor2D.new("Player"), Player)
    
    -- Visual via Nó Filho
    self.sprite = AnimatedSprite2D.new("assets/hero.png", 32, 32)
    self.sprite:add_animation("run", {1, 2, 3, 4}, 0.1, true)
    self.sprite:play("run")
    self:add_child(self.sprite)

    -- Alarme estilo GameMaker (sem criar nós extras de Timer)
    self.can_dash = true
    self:set_alarm(0, 2.0, function()
        self.can_dash = true
    end, false)

    return self
end

function Player:_process(dt)
    -- Controles estilo Godot
    local move_x = 0
    if aplua.input.is_down("right") then move_x = move_x + 1 end
    if aplua.input.is_down("left")  then move_x = move_x - 1 end

    -- Movimentação rápida estilo GameMaker
    self.hspeed = move_x * 160

    if aplua.input.is_just_pressed("dash") and self.can_dash then
        self.hspeed = self.hspeed * 3
        self.can_dash = false
        self:start_alarm(0)
    end
end

-- Espaço de mundo (afetado pelo zoom e posição da Camera2D)
function Player:_draw()
    -- Renderizações contextuais no mundo (ex: sombras, miras)
end

-- Espaço de tela (HUD fixo)
function Player:_draw_gui()
    if not self.can_dash then
        love.graphics.print("Dash em Recarga...", 20, 20)
    end
end

return Player

```

---

## 📁 Estrutura Planejada

```text
aplua/
├── .devcontainer/                # Ambiente Codespaces (LÖVE2D + Desktop Web)
│   └── devcontainer.json
│
├── aplua/                        # 🌿 CÓDIGO DA ENGINE
│   ├── init.lua                  # Ponto de entrada global (aplua.*)
│   │
│   ├── core/                     # Núcleo Arquitetural
│   │   ├── object.lua            # Herança e metatabelas
│   │   ├── node.lua              # O Nó fundamental (árvore, hierarquia e ciclo de vida)
│   │   ├── node_2d.lua           # Nó espacial 2D (coordenadas locais/globais e rotação)
│   │   ├── scene_tree.lua        # Loop principal (integração com love.update/draw/draw_gui)
│   │   ├── signals.lua           # Sistema desacoplado de eventos (Observer)
│   │   └── alarms.lua            # Gerenciador de temporizadores leves
│   │
│   ├── nodes/                    # Biblioteca de Nós Especializados
│   │   ├── actor_2d.lua          # Nó com cinemática GM (hspeed, vspeed, speed, alarms)
│   │   ├── sprite_2d.lua         # Texturas estáticas com controle de pivô/origem
│   │   ├── animated_sprite_2d.lua# Animação de spritesheets com tags de ação
│   │   ├── camera_2d.lua         # Câmera com interpolação suave (lerp) e limites
│   │   └── canvas_layer.lua      # Camadas de renderização ordenadas por Z-index
│   │
│   ├── systems/                  # Subsistemas do Runtime
│   │   ├── input.lua             # Mapeamento de botões e ações virtuais
│   │   ├── scenes.lua            # Carregador e trocador de Cenas/Salas com persistência
│   │   └── physics2d.lua         # Detecção simples de colisão (AABB e máscaras)
│   │
│   └── math/                     # Utilitários Matemáticos
│       └── vector2.lua           # Vetores 2D, ângulos e interpolações
│
├── sandbox/                      # 🎮 PROJETO DE TESTE / EXEMPLO
│   ├── assets/
│   └── scenes/
│       └── main_room.lua
│
├── conf.lua                      # Configurações do LÖVE2D
├── main.lua                      # Bootstrap que inicializa a SceneTree
└── README.md

```

---

## 🗺️ Roteiro de Desenvolvimento (Roadmap)

* [x] **Fase 0: Concepção e Arquitetura Híbrida**
  - Definição do escopo combinando Scene Tree (Godot) com Cinemática/Alarmes/GUI (GameMaker).
* [ ] **Fase 1: Núcleo e Hierarquia (Core)**
  - Configuração do Dev Container (LÖVE2D + Desktop Web).
  - Implementação de `Object`, `Node` e `Node2D` (árvore e matrizes de transformação relativa).
  - Implementação da `SceneTree` com suporte aos dois passos de renderização (`_draw` e `_draw_gui`).
* [ ] **Fase 2: O Nó Ator e Gráficos**
  - Criação do `Actor2D` (`hspeed`, `vspeed`, `friction`, `alarm`).
  - Implementação de `Sprite2D` e `AnimatedSprite2D`.
  - Criação da `Camera2D` (seguimento suave e separação de matrizes tela/mundo).
* [ ] **Fase 3: Entradas, Sinais e Colisões**
  - Sistema de Input unificado (`is_action_pressed`, `is_action_just_pressed`).
  - Sistema de Sinais desacoplados (`connect`, `emit`).
  - Colisões 2D diretas com detecção AABB e callback `_on_collision(other)`.
* [ ] **Fase 4: Gestão de Salas e Persistência**
  - Sistema de transição de salas mantendo nós com `persistent = true`.
  - Serialização e carregamento de cenas em formato tabular Lua.
* [ ] **Fase 5: Ferramentas e Editor Visual**
  - Canvas interativo para posicionamento de nós via Drag & Drop.
  - Inspetor de propriedades e navegador de árvore de nós.
