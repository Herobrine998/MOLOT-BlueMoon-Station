// Цена каждой записи указана в кредитах за всю позицию, до бонусов за тир и полноту заказа.
// Формат: тип = список(русская подпись, количество, базовая выплата).
/datum/cargo_quest_catalog
	var/department
	var/tier = 1
	var/kind = CARGO_QUEST_ITEM
	var/list/targets = list()

/datum/cargo_quest_catalog/organs
	department = CARGO_QUEST_MEDICAL
	targets = list(
		/obj/item/organ/heart = list("Сердце", 1, 3000),
		/obj/item/organ/lungs = list("Лёгкие", 3, 7000),
		/obj/item/organ/liver = list("Печень", 3, 8500),
		/obj/item/organ/eyes = list("Органические глаза", 3, 6000),
		/obj/item/organ/ears = list("Уши", 3, 8000),
		/obj/item/organ/tongue = list("Язык", 3, 6500),
		/obj/item/organ/appendix = list("Аппендикс", 1, 4500),
		/obj/item/organ/stomach = list("Желудок", 1, 3000),
	)

/datum/cargo_quest_catalog/rare_organs
	department = CARGO_QUEST_MEDICAL
	tier = 3
	targets = list(
		/obj/item/organ/heart/slime = list("Сердце слаймолюда", 1, 9500),
		/obj/item/organ/lungs/slime = list("Лёгкие слаймолюда", 1, 9500),
		/obj/item/organ/liver/slime = list("Печень слаймолюда", 1, 9500),
		/obj/item/organ/stomach/slime = list("Желудок слаймолюда", 1, 9500),
		/obj/item/organ/lungs/plasmaman = list("Лёгкие плазмамена", 1, 13000),
		/obj/item/organ/liver/plasmaman = list("Печень плазмамена", 1, 13000),
		/obj/item/organ/stomach/plasmaman = list("Желудок плазмамена", 1, 13000),
	)

/datum/cargo_quest_catalog/chemistry
	department = CARGO_QUEST_MEDICAL
	tier = 2
	kind = CARGO_QUEST_REAGENT
	targets = list(
		/datum/reagent/medicine/leporazine = list("Лепоразин", 30, 4000),
		/datum/reagent/medicine/clonexadone = list("Клонексадон", 30, 4500),
		/datum/reagent/medicine/pyroxadone = list("Пироксадон", 30, 5000),
		/datum/reagent/medicine/rezadone = list("Резадон", 30, 5000),
		/datum/reagent/medicine/pen_acid = list("Пентетовая кислота", 30, 4500),
		/datum/reagent/medicine/perfluorodecalin = list("Перфтордекалин", 30, 4500),
		/datum/reagent/medicine/ephedrine = list("Эфедрин", 30, 4000),
		/datum/reagent/medicine/diphenhydramine = list("Дифенгидрамин", 30, 4000),
		/datum/reagent/medicine/atropine = list("Атропин", 30, 4500),
		/datum/reagent/medicine/strange_reagent = list("Странный реагент", 30, 6000),
		/datum/reagent/medicine/regen_jelly = list("Регенеративное желе", 30, 6000),
		/datum/reagent/napalm = list("Напалм", 30, 4000),
		/datum/reagent/teslium = list("Теслий", 30, 4500),
		/datum/reagent/firefighting_foam = list("Противопожарная пена", 30, 4000),
	)

/datum/cargo_quest_catalog/mutations
	department = CARGO_QUEST_MEDICAL
	tier = 4
	kind = CARGO_QUEST_MUTATION
	targets = list(
		/datum/mutation/human/hulk = list("Неиспользованный ДНК-инъектор: Халк", 1, 6000),
		/datum/mutation/human/telekinesis = list("Неиспользованный ДНК-инъектор: телекинез", 1, 6000),
		/datum/mutation/human/chameleon = list("Неиспользованный ДНК-инъектор: хамелеон", 1, 5000),
		/datum/mutation/human/laser_eyes = list("Неиспользованный ДНК-инъектор: лазерные глаза", 1, 6500),
	)

/datum/cargo_quest_catalog/viruses
	department = CARGO_QUEST_MEDICAL
	tier = 4
	kind = CARGO_QUEST_VIRUS
	targets = list(
		/datum/symptom/shivering = list("Образец крови от 10 ед. с симптомом «Озноб»", 1, 4300),
		/datum/symptom/sneeze = list("Образец крови от 10 ед. с симптомом «Чихание»", 1, 4300),
		/datum/symptom/itching = list("Образец крови от 10 ед. с симптомом «Зуд»", 1, 4300),
		/datum/symptom/oxygen = list("Образец крови от 10 ед. с симптомом удушья", 1, 4300),
	)

/datum/cargo_quest_catalog/minerals
	department = CARGO_QUEST_MINING
	targets = list(
		/obj/item/stack/sheet/metal = list("Металл", 50, 2000),
		/obj/item/stack/sheet/glass = list("Стекло", 50, 1500),
		/obj/item/stack/sheet/plasteel = list("Пласталь", 30, 5100),
		/obj/item/stack/sheet/mineral/plasma = list("Твёрдая плазма", 30, 6000),
		/obj/item/stack/sheet/mineral/silver = list("Серебро", 15, 4500),
		/obj/item/stack/sheet/mineral/gold = list("Золото", 15, 5000),
		/obj/item/stack/sheet/mineral/titanium = list("Титан", 15, 3000),
		/obj/item/stack/sheet/mineral/uranium = list("Уран", 15, 4500),
		/obj/item/stack/sheet/mineral/diamond = list("Алмазы", 7, 11000),
		/obj/item/stack/sheet/bluespace_crystal = list("Блюспейс-кристаллы", 7, 11000),
		/obj/item/stack/sheet/mineral/bananium = list("Бананиум", 4, 17000),
	)

/datum/cargo_quest_catalog/trophies
	department = CARGO_QUEST_MINING
	tier = 2
	targets = list(
		/obj/item/crusher_trophy/goliath_tentacle = list("Щупальце голиафа", 1, 6000),
		/obj/item/crusher_trophy/watcher_wing = list("Крыло наблюдателя", 1, 5000),
		/obj/item/crusher_trophy/legion_skull = list("Череп легиона", 1, 6000),
	)

/datum/cargo_quest_catalog/mining_crafts
	department = CARGO_QUEST_MINING
	tier = 3
	targets = list(
		/obj/item/fireaxe/boneaxe = list("Костяной топор", 1, 4500),
		/obj/item/clothing/suit/armor/bone = list("Костяная броня", 1, 3000),
		/obj/item/clothing/head/helmet/skull = list("Шлем из черепа", 1, 3000),
		/obj/item/clothing/accessory/talisman = list("Костяной талисман", 3, 4500),
		/obj/item/kitchen/knife/combat/bone = list("Костяной кинжал", 3, 5000),
	)

/datum/cargo_quest_catalog/megafauna
	department = CARGO_QUEST_MINING
	tier = 4
	targets = list(
		/obj/item/crusher_trophy/miner_eye = list("Глаз кровожадного шахтёра", 1, 15000),
		/obj/item/crusher_trophy/tail_spike = list("Хвостовой шип дракона", 1, 20000),
		/obj/item/crusher_trophy/demon_claws = list("Когти Бубльгума", 1, 25000),
		/obj/item/crusher_trophy/blaster_tubes = list("Бластерные трубки колосса", 1, 20000),
		/obj/item/crusher_trophy/vortex_talisman = list("Вихревой талисман иерофанта", 1, 20000),
	)

/datum/cargo_quest_catalog/food
	department = CARGO_QUEST_SERVICE
	targets = list(
		/obj/item/reagent_containers/food/snacks/friedegg = list("Яичница", 5, 2500),
		/obj/item/reagent_containers/food/snacks/omelette = list("Омлет", 5, 3000),
		/obj/item/reagent_containers/food/snacks/burger/tofu = list("Тофу-бургер", 5, 3500),
		/obj/item/reagent_containers/food/snacks/burger/cheese = list("Чизбургер", 5, 3500),
		/obj/item/reagent_containers/food/snacks/icecreamsandwich = list("Сэндвич с мороженым", 5, 4300),
		/obj/item/reagent_containers/food/snacks/hotdog = list("Хот-дог", 5, 4000),
	)

/datum/cargo_quest_catalog/food_advanced
	department = CARGO_QUEST_SERVICE
	tier = 2
	targets = list(
		/obj/item/reagent_containers/food/snacks/soup/monkeysdelight = list("Обезьянье удовольствие", 3, 5000),
		/obj/item/reagent_containers/food/snacks/burger/superbite = list("Супербургер", 3, 5500),
		/obj/item/reagent_containers/food/snacks/soup/beet = list("Свекольный суп", 5, 4500),
	)

/datum/cargo_quest_catalog/food_rare
	department = CARGO_QUEST_SERVICE
	tier = 3
	targets = list(
		/obj/item/reagent_containers/food/snacks/rofflewaffles = list("Рофл-вафли", 3, 6000),
		/obj/item/reagent_containers/food/snacks/salad/aesirsalad = list("Салат асов", 3, 6000),
		/obj/item/reagent_containers/food/snacks/soup/amanitajelly = list("Мухоморное желе", 3, 5000),
	)

/datum/cargo_quest_catalog/seeds
	department = CARGO_QUEST_SERVICE
	kind = CARGO_QUEST_SEED
	targets = list(
		/obj/item/seeds/tomato = list("Семена томата", 10, 2000),
		/obj/item/seeds/banana = list("Семена банана", 10, 2000),
		/obj/item/seeds/wheat = list("Семена пшеницы", 10, 2000),
		/obj/item/seeds/carrot = list("Семена моркови", 10, 2000),
		/obj/item/seeds/potato = list("Семена картофеля", 10, 2000),
		/obj/item/seeds/soya = list("Семена сои", 10, 2000),
		/obj/item/seeds/sunflower = list("Семена подсолнуха", 10, 2000),
		/obj/item/seeds/nettle = list("Семена крапивы", 10, 2000),
	)

/datum/cargo_quest_catalog/mutant_seeds
	department = CARGO_QUEST_SERVICE
	tier = 2
	kind = CARGO_QUEST_SEED
	targets = list(
		/obj/item/seeds/tomato/blue/bluespace = list("Семена блюспейс-томата", 10, 5000),
		/obj/item/seeds/banana/bluespace = list("Семена блюспейс-банана", 10, 5000),
		/obj/item/seeds/ambrosia/gaia = list("Семена амброзии Гайя", 10, 5000),
		/obj/item/seeds/nettle/death = list("Семена смертельной крапивы", 10, 5000),
		/obj/item/seeds/apple/gold = list("Семена золотого яблока", 10, 5000),
		/obj/item/seeds/sunflower/novaflower = list("Семена новоцвета", 10, 5000),
	)

/datum/cargo_quest_catalog/plant_genes
	department = CARGO_QUEST_SERVICE
	tier = 2
	kind = CARGO_QUEST_PLANT_GENE
	targets = list(
		/datum/plant_gene/trait/plant_type/fungal_metabolism = list("Диск с геном грибного метаболизма", 1, 3000),
		/datum/plant_gene/trait/squash = list("Диск с геном раздавливания", 1, 3000),
		/datum/plant_gene/trait/repeated_harvest = list("Диск с геном многократного урожая", 1, 3000),
		/datum/plant_gene/trait/maxchem = list("Диск с геном сгущения реагентов", 1, 3000),
		/datum/plant_gene/trait/stinging = list("Диск с геном жгучести", 1, 4500),
		/datum/plant_gene/trait/glow = list("Диск с геном свечения", 1, 5000),
		/datum/plant_gene/trait/battery = list("Диск с геном растения-батареи", 1, 5500),
		/datum/plant_gene/trait/slip = list("Диск с геном скользкой кожицы", 1, 5500),
		/datum/plant_gene/trait/teleport = list("Диск с геном блюспейс-активности", 1, 6500),
	)

/datum/cargo_quest_catalog/plant_genes_rare
	department = CARGO_QUEST_SERVICE
	tier = 3
	kind = CARGO_QUEST_PLANT_GENE
	targets = list(
		/datum/plant_gene/trait/fire_resistance = list("Диск с геном огнестойкости", 1, 8000),
		/datum/plant_gene/trait/smoke = list("Диск с геном дымообразования", 1, 10000),
		/datum/plant_gene/trait/glow/shadow = list("Диск с геном поглощения света", 1, 8000),
	)

/datum/cargo_quest_catalog/botanical_reagents
	department = CARGO_QUEST_SERVICE
	tier = 2
	kind = CARGO_QUEST_REAGENT
	targets = list(
		/datum/reagent/consumable/honey = list("Мёд", 30, 4000),
		/datum/reagent/consumable/frostoil = list("Морозное масло", 30, 4500),
		/datum/reagent/toxin/amanitin = list("Аманитин", 30, 4500),
		/datum/reagent/toxin/cyanide = list("Цианид", 30, 4500),
	)

/datum/cargo_quest_catalog/drinks
	department = CARGO_QUEST_SERVICE
	tier = 2
	kind = CARGO_QUEST_REAGENT
	targets = list(
		/datum/reagent/consumable/ethanol/b52 = list("Б-52", 30, 3500),
		/datum/reagent/consumable/ethanol/beepsky_smash = list("Удар Бипски", 30, 3500),
		/datum/reagent/consumable/ethanol/demonsblood = list("Кровь демона", 30, 4000),
		/datum/reagent/consumable/ethanol/bacchus_blessing = list("Благословение Бахуса", 30, 5500),
		/datum/reagent/consumable/ethanol/hippies_delight = list("Радость хиппи", 30, 5500),
		/datum/reagent/consumable/ethanol/neurotoxin = list("Нейротоксин", 30, 5500),
		/datum/reagent/consumable/ethanol/singulo = list("Сингуло", 30, 4500),
	)

/datum/cargo_quest_catalog/science_tools
	department = CARGO_QUEST_SCIENCE
	targets = list(
		/obj/item/gun/energy/floragun = list("Флора-соматорай", 1, 3000),
		/obj/item/gun/syringe/rapidsyringe = list("Скоростной шприцемёт", 3, 3000),
		/obj/item/clothing/shoes/magboots = list("Магнитные ботинки", 2, 3000),
		/obj/item/gun/energy/temperature = list("Температурная пушка", 2, 3000),
		/obj/item/organ/lungs/cybernetic/tier2 = list("Улучшенные кибернетические лёгкие", 3, 3500),
		/obj/item/organ/heart/cybernetic/tier2 = list("Улучшенное кибернетическое сердце", 3, 3500),
		/obj/item/reagent_containers/glass/beaker/noreact = list("Криостазисный химический стакан", 10, 3000),
	)

/datum/cargo_quest_catalog/science_bluespace
	department = CARGO_QUEST_SCIENCE
	tier = 2
	targets = list(
		/obj/item/lightreplacer/blue = list("Блюспейс-заменитель ламп", 5, 4000),
		/obj/item/storage/bag/trash/bluespace = list("Блюспейс-мусорный мешок", 2, 5000),
		/obj/item/stock_parts/cell/bluespace = list("Блюспейс-батарея", 10, 5000),
		/obj/item/reagent_containers/glass/beaker/bluespace = list("Блюспейс-стакан", 5, 4000),
		/obj/item/storage/backpack/holding = list("Блюспейс-рюкзак", 2, 8000),
		/obj/item/storage/backpack/holding/satchel = list("Блюспейс-сумка", 2, 8000),
	)

/datum/cargo_quest_catalog/slimes
	department = CARGO_QUEST_SCIENCE
	tier = 3
	targets = list(
		/obj/item/slime_extract/grey = list("Серый экстракт слайма", 6, 4500),
		/obj/item/slime_extract/orange = list("Оранжевый экстракт слайма", 6, 4500),
		/obj/item/slime_extract/purple = list("Фиолетовый экстракт слайма", 6, 4500),
		/obj/item/slime_extract/blue = list("Синий экстракт слайма", 6, 4500),
		/obj/item/slime_extract/metal = list("Металлический экстракт слайма", 6, 4500),
		/obj/item/slime_extract/yellow = list("Жёлтый экстракт слайма", 6, 4500),
		/obj/item/slime_extract/darkblue = list("Тёмно-синий экстракт слайма", 6, 4500),
		/obj/item/slime_extract/darkpurple = list("Тёмно-фиолетовый экстракт слайма", 6, 4500),
		/obj/item/slime_extract/silver = list("Серебряный экстракт слайма", 6, 4500),
		/obj/item/slime_extract/bluespace = list("Блюспейс-экстракт слайма", 6, 5000),
		/obj/item/slime_extract/sepia = list("Сепиевый экстракт слайма", 6, 5000),
		/obj/item/slime_extract/cerulean = list("Лазурный экстракт слайма", 6, 5000),
		/obj/item/slime_extract/pyrite = list("Пиритовый экстракт слайма", 6, 5000),
		/obj/item/slime_extract/green = list("Зелёный экстракт слайма", 6, 5000),
		/obj/item/slime_extract/red = list("Красный экстракт слайма", 6, 5000),
		/obj/item/slime_extract/pink = list("Розовый экстракт слайма", 6, 5000),
		/obj/item/slime_extract/gold = list("Золотой экстракт слайма", 6, 5000),
		/obj/item/slime_extract/adamantine = list("Адамантиновый экстракт слайма", 6, 5500),
		/obj/item/slime_extract/oil = list("Масляный экстракт слайма", 6, 5500),
		/obj/item/slime_extract/black = list("Чёрный экстракт слайма", 6, 5500),
		/obj/item/slime_extract/lightpink = list("Светло-розовый экстракт слайма", 6, 5500),
	)

/datum/cargo_quest_catalog/alien_organs
	department = CARGO_QUEST_SCIENCE
	tier = 4
	targets = list(
		/obj/item/organ/alien/plasmavessel = list("Плазменный сосуд ксеноморфа", 1, 15000),
		/obj/item/organ/alien/plasmavessel/small = list("Малый плазменный сосуд ксеноморфа", 1, 15000),
		/obj/item/organ/brain/alien = list("Мозг ксеноморфа", 1, 15000),
		/obj/item/organ/tongue/alien = list("Язык ксеноморфа", 1, 15000),
		/obj/item/slime_extract/rainbow = list("Радужный экстракт слайма", 6, 10000),
	)

// Проверяется наличие указанной ноды в данных диска, а не его название или оформление.
/datum/cargo_quest_catalog/tech_nodes
	department = CARGO_QUEST_SCIENCE
	kind = CARGO_QUEST_TECH_NODE
	targets = list(
		/datum/techweb_node/biotech = list("Диск с нодой «Биологические технологии»", 1, 1500),
		/datum/techweb_node/bluespace_basic = list("Диск с нодой «Основы блюспейс-теории»", 1, 1500),
		/datum/techweb_node/basic_tools = list("Диск с нодой «Базовые инструменты»", 1, 1500),
	)

/datum/cargo_quest_catalog/tech_nodes_advanced
	department = CARGO_QUEST_SCIENCE
	tier = 2
	kind = CARGO_QUEST_TECH_NODE
	targets = list(
		/datum/techweb_node/practical_bluespace = list("Диск с нодой «Прикладные блюспейс-исследования»", 1, 2500),
		/datum/techweb_node/adv_biotech = list("Диск с нодой «Продвинутые биотехнологии»", 1, 2500),
		/datum/techweb_node/exp_tools = list("Диск с нодой «Экспериментальные инструменты»", 1, 2500),
	)

/datum/cargo_quest_catalog/tech_nodes_rare
	department = CARGO_QUEST_SCIENCE
	tier = 3
	kind = CARGO_QUEST_TECH_NODE
	targets = list(
		/datum/techweb_node/adv_bluespace = list("Диск с нодой «Продвинутые блюспейс-исследования»", 1, 4000),
		/datum/techweb_node/bluespace_power = list("Диск с нодой «Блюспейс-энергетика»", 1, 4000),
		/datum/techweb_node/bluespace_holding = list("Диск с нодой «Блюспейс-карманы»", 1, 4000),
	)

/datum/cargo_quest_catalog/tech_nodes_expert
	department = CARGO_QUEST_SCIENCE
	tier = 4
	kind = CARGO_QUEST_TECH_NODE
	targets = list(
		/datum/techweb_node/bluespace_portal = list("Диск с нодой «Блюспейс-порталы»", 1, 5000),
		/datum/techweb_node/bluespace_warping = list("Диск с нодой «Блюспейс-перемещение»", 1, 5000),
		/datum/techweb_node/emp_super = list("Диск с нодой «Квантовые электромагнитные технологии»", 1, 5000),
	)
