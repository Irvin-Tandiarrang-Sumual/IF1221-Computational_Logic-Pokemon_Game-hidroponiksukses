:- dynamic(inventory/1).
:- dynamic(legendary/1).
:- dynamic(jml_inventory/1).
:- dynamic(playerPos/2).
:- dynamic(base_stats/4).
:- dynamic(poke_stats/5).
:- dynamic(posisiPokemon/3).
:- dynamic(battleNow/1).
:- dynamic(curr_health/2).
:- dynamic(isOnPoke/1).
:- dynamic(isBattle/1).
:- dynamic(level/4).
:- dynamic(skill/5).
:- dynamic(health/2).

/* Pokemon */
/* List pokemon */
/* pokemon(ID, Nama_pokemon, Rarity) */
pokemon(1, charmander, common).
pokemon(2, squirtle, common).
pokemon(3, pidgey, common).
pokemon(4, charmeleon, common).
pokemon(5, wartortle, common).
pokemon(6, pikachu, rare).
pokemon(7, geodude, rare).
pokemon(8, snorlax, epic).
pokemon(9, articuno, legendary).
pokemon(10, mewtwo, legendary).

/* Type */
/* type(Type, Nama_pokemon) */
type(flying, pidgey).
type(ice, articuno).
type(electric, pikachu).
type(normal, snorlax).
type(rock, geodude).
type(fire, charmander).
type(water, squirtle).
type(fire, charmeleon).
type(water, wartortle).
type(psychic, mewtwo).

starter(charmander).
starter(squirtle).
starter(pidgey).


legendary(articuno).
legendary(mewtwo).

/* Base stats */
/* base_stats(HP, ATK, DEF, Nama_pokemon) */
base_stats(30, 14, 10, pidgey).
base_stats(60, 28, 35, articuno).
base_stats(30, 16, 10, pikachu).
base_stats(70, 30, 20, snorlax).
base_stats(30, 20, 25, geodude).
base_stats(35, 15, 10, charmander).
base_stats(40, 12, 15, squirtle).
base_stats(35, 15, 10, charmeleon).
base_stats(40, 12, 15, wartortle).
base_stats(250, 300, 250, wartortle).
base_stats(250, 300, 250, mewtwo).

/* level Pokemon */
/* level(Level, Nama_pokemon, Slot_Inventory, EXP_Counter) */
level(5,pidgey,0, 0).
level(5,charmander,0, 0).
level(5,squirtle,0, 0).

/* Poke stats */
/* poke_stats(HP, ATK, DEF, Nama_pokemon, Slot_Inventory) */

/* modifier */
/* superEffective(T1,T2) : T1 is super effective against T2 */
/* notEffective(T1,T2) : T1 is not too effective against T2*/
superEffective(fire, ice).
superEffective(water, fire).
superEffective(water, rock).
superEffective(rock, fire).
superEffective(rock, flying).
superEffective(rock, ice).
superEffective(ice, flying).

notEffective(fire, water).
notEffective(fire, rock).
notEffective(fire, fire).
notEffective(water, electric).
notEffective(water, water).
notEffective(electric, electric).
notEffective(electric, rock).
notEffective(flying, electric).
notEffective(flying, rock).
notEffective(flying, ice).
notEffective(rock, water).
notEffective(rock, rock).
notEffective(ice, fire).
notEffective(ice, rock).
notEffective(ice, water).
notEffective(ice, ice).
notEffective(normal, rock).

/* Skill */
/* skill(Nama_skill, Type, Power, Ability, Ability_chance) */
skill(tackle, normal, 35, none, 0).
skill(scratch, normal, 35, none, 0).
skill(ember, fire, 40, burn(2, 3), 1.0).
skill(water_gun, water, 40, none, 0).
skill(gust, flying, 30, none, 0).
skill(fire_spin, fire, 35, burn(2, 5), 1.0).
skill(bubble, water, 30, lower_atk(3), 1.0).
skill(thunder_shock, electric, 40, paralyze, 0.2).
skill(quick_attack, normal, 30, none, 0).
skill(rock_throw, rock, 50, none, 0).
skill(rest, normal, 0, heal(0.4), 1.0).
skill(ice_shard, ice, 40, none, 0).
skill(psychic_blast, psychic, 25, paralyze, 0.2).
skill(mind_shock, psychic, 20, area, 1.0).

isOnPoke(0).
isBattle(0).

/* special trait mewtwo dengan id 10*/
/* immune_status(id pokemon) */
immune_status(10).

/* Rarity */
/* rarity(Rarity, BaseEXP, BaseEXPGiven, CatchRate) */
rarity(common, 20, 10, 40).
rarity(rare, 30, 20, 30).
rarity(epic, 40, 30, 25).
rarity(legendary, 50, 40, 20).