# work-ant-agents

Este repositório contém o código e a documentação para o projeto **work-ant-agents**, desenvolvido durante a disciplina de **Inteligência Artificial** da **Universidade Federal do Maranhão (UFMA)**. O projeto utiliza o framework **NetLogo** para modelar um ecossistema complexo onde formigas de diferentes raças competem pela busca de alimentação e domínio de território.

---

## 🐜 **Descrição do Projeto**

### **Os Formigueiros**

- **Formação Inicial**: Os formigueiros surgem em um ponto determinado do mapa, com uma área delimitada.
- **Comportamento das formigas**:
- **Trabalhadora(worker-behavior)**: Procura e coleta comida no ambiente, segue trilhas de feromônio da própria colônia e volta ao ninho com a comida, além de deixar trilhas de feromônio.
- **Exploradora (explorer-behavior)**: Procura áreas não exploradas e marca fontes de comida com feromônio intenso, além de evitar as áreas já exploradas.
- **Guerreira (warrior-behavior)**: Ataca formigas de outras colônias e se mantém próxima ao ninho para proteger o território da colônia.

### **Sistema climático**

### **Tipos de clima**

1. **Normal**: Condições ideais:

- Difusão: 100% da taxa base
- Evaporação: 100% da taxa base
- Efeitos: Recuperação de saúde

2. **Chuvoso**: Chuvoso: Reduz difusão de feromônios:

- Difusão: 50% da taxa base
- Evaporação: 150% da taxa base
- Efeitos: Feromônios se espalham menos

3. **Chuvoso**: Aumenta difusão e evaporação:

- Difusão: 150% da taxa base
- Evaporação: 200% da taxa base
- Efeitos: Feromônios se espalham mais mas evaporam rapidamente

4. **Tempestade**: Condições severas:

- Difusão: 20% da taxa base
- Evaporação: 250% da taxa base
- Efeitos: Desorientação (20% chance), dano (5% chance)

5. **Neve**:Condições extremas:

- Difusão: 30% da taxa base
- Evaporação: 70% da taxa base
- Efeitos: Movimento lento (70% chance), dano por frio (2% chance)

### **Os Predadores**

- Divididos em dois: **Tamanduás** e **Cobras**

- **Tamanduás (anteater-behavior)**:
- pawn: 1/1500 chance por tick
- Poder: 40-59
- Comportamento: Caça formigas em raio de 2 patches
- Duração: 200 ticks antes de desaparecer
- Movimento: Aleatório (velocidade 0.7)

- **Cobras (boa-behavior)**:
- Spawn: 1/3000 chance por tick
- Poder: 70-99
- Comportamento: Caça tamanduás primeiro, depois formigas
- Duração: 300 ticks antes de desaparecer
- Movimento: Mais lento (velocidade 0.4)

### ⚔️ **Sistemas de combate** ⚔️

**Mecânica**

- **Iniciador**: Guerreiras atacam inimigos em raio de 3 patches
- **Cálculo**: random strength > random enemy-strength
- **Dano**: 20 pontos de saúde
- **Morte**: Quando saúde chega a 0

**Balanceamento**

- **Colônia Vermelha**: Força média, saúde média
- **Colônia Azul**: Mais forte e resistente
- **Colônia Verde**: Mais fraca mas mais ágil

---

## 🚀 **Como Rodar o Projeto**

1. Baixe e instale o **NetLogo**.
2. Clone este repositório.
3. Abra o arquivo `.nlogo` no NetLogo.
4. Execute a simulação e observe a evolução do formigueiro e as interações com o ambiente.

---

## 📚 **Conceitos Aplicados**

- **Modelagem Baseada em Agentes (ABM)**: Simulação de comportamentos individuais para observar fenômenos emergentes.
- **Inteligência Artificial**: Implementação de decisões estratégicas por parte dos agentes.
- **Evolução e Adaptação**: Comportamentos e características dos agentes se ajustam ao ambiente dinâmico.

---

## 🏛 **Universidade Federal do Maranhão (UFMA)**

Disciplina: **Inteligência Artificial**  
Discentes: Gabryel Guimarães, Antonio Claudino, Nickolas Ferreira, Maria Luiza.
