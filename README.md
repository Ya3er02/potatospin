# 🥔 Potato Pet - Virtual Pet Game

**Now Featuring**: Full Virtual Pet Mechanics with Tamagotchi-inspired gameplay!

🎮 **Live Demo**: https://rawcdn.githack.com/Ya3er02/potatospin/main/index.html

## Recent Transformation (Phase 2)

PotatoSpin has evolved from a simple Spinning Wheel into a complete Virtual Pet game inspired by POUPY.

### What Changed:
- ✅ Replaced spinning wheel game with Virtual Pet mechanics  
- ✅ Added 3-stat system (Hunger, Happiness, Cleanliness)
- ✅ Implemented game loop with 1-second stat decay
- ✅ Spinning wheel now provides random pet actions (feed, play, bathe, sleep)
- ✅ Level & XP progression system
- ✅ localStorage save/load with offline stat decay
- ✅ Pet survival mechanics (pet dies if stats reach zero)

## 🎮 Game Features

### Pet Mechanics
- **Virtual Potato Character** - 🥔 grows with you
- **3 Core Stats**:
  - 🍗 Hunger: Decreases 2 points/sec (max 150)
  - 💛 Happiness: Decreases 1 point/sec (max 150)
  - 🧼 Cleanliness: Decreases 0.5 points/sec (max 150)
- **Pet States**: Healthy, Hungry, Sad, Dirty, Dead
- **Survival**: Pet dies if any stat reaches 0

### Spin Wheel System
Instead of random prizes, the wheel determines pet actions:
- **🍽️ FOOD** (33%): Feed pet +30 hunger
- **🎮 PLAY** (17%): Play +25 happiness, -5 hunger
- **🚿 BATH** (17%): Bathe +30 cleanliness, -3 hunger  
- **😴 SLEEP** (17%): Restore all stats significantly
- **✨ BONUS** (8%): +50 XP (double rewards)
- **💔 FAIL** (8%): No effect

### Progression
- **Level System**: 1-50+ levels
- **XP Gain**: +10 XP per spin, +5 XP per stat recovery
- **Level Up Rewards**: Character growth + stat boost + new abilities
- **Dynamic XP Curve**: Requirement scales 1.1x per level

### Persistence
- Save/Load with localStorage
- Offline decay calculation (stats decrease while away)
- Auto-save every action
- Progress recovery on page reload

## 📊 Original Spinning Wheel (Legacy)

*The original spin-to-win game is now integrated as the primary interaction method. No token economy on-chain yet (Phase 3 feature).*

## 🛠️ Technical Stack

- **Frontend**: Pure HTML/CSS/JavaScript (no frameworks)
- **Persistence**: localStorage with JSON serialization
- **Canvas**: 2D wheel drawing with HTML5 Canvas API
- **Game Loop**: requestAnimationFrame at 60 FPS (decoupled from UI updates)
- **State Machine**: Pet states + action queue system

## 🚀 Game Architecture (POUPY-Inspired)

```
Index.html
├── HTML/CSS UI Structure
├── PotatoPet Class (Pet logic)
├── Spin Wheel System (6 outcomes)
├── Game Loop (update + render)
├── localStorage Manager (persistence)
└── Event Handlers (clicks)
```

## 📱 How to Play

1. **Load Game** - Page automatically loads saved progress
2. **Monitor Stats** - Watch the 3 stat bars
3. **Spin the Wheel** - Click "SPIN THE WHEEL! 🎡"
4. **Pet Responds** - Gets fed, plays, bathes, or sleeps
5. **Level Up** - Collect XP to grow your pet
6. **Keep Alive** - Don't let any stat hit zero!
7. **Save Progress** - Automatically saved to localStorage

## 🔐 Security Features

- Input validation on all stat operations
- No eval() or unsafe code execution
- localStorage quota management
- Offline-safe state calculations
- XSS protection via textContent

## 📈 Roadmap

### Phase 3: Backend & Blockchain
- [ ] Smart contracts (POTATO token ERC-20)
- [ ] NFT minting for milestones
- [ ] Leaderboard API
- [ ] Cloud save backup

### Phase 4: Advanced Features
- [ ] Pet breeding system
- [ ] Mini-games beyond spinning
- [ ] Social features (trade pets)
- [ ] Seasonal events

## 📄 License

MIT License - See LICENSE file

## 🙏 Inspirations

- **POUPY** - Virtual Pet game architecture (GitHub: mts-lucas/POUPY)
- **Tamagotchi** - Classic pet game mechanics
- **Ethereum** - Future blockchain integration

---

**Made with 🥔 by Ya3er02**
