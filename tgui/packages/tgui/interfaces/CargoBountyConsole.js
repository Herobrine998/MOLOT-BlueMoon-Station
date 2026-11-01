import { useState } from 'react';

import { useBackend } from '../backend';
import {
  AnimatedNumber,
  Box,
  Button,
  Icon,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Table,
  Tabs,
} from '../components';
import { formatMoney } from '../format';
import { Window } from '../layouts';

const groups = [
  { id: 'centcomm', label: 'Структуры НТ', icon: 'mail-bulk' },
  { id: 'corporation', label: 'Частные заказчики', icon: 'dollar-sign' },
  { id: 'plasma', label: 'Поставка плазмы', icon: 'fire' },
  { id: 'management', label: 'Менеджмент', icon: 'info' },
];
const tierColors = ['green', 'yellow', 'orange', 'purple'];
const formatTimer = seconds =>
  `${Math.floor(seconds / 60)}:${String(seconds % 60).padStart(2, '0')}`;

export const CargoBountyConsole = () => {
  const { data } = useBackend();
  const { quests = [] } = data;
  const [tab, setTab] = useState('centcomm');
  const visible = quests.filter(quest => quest.customer === tab);
  const rows = [];
  for (let i = 0; i < visible.length; i += 2) {
    rows.push(visible.slice(i, i + 2));
  }
  return (
    <Window width={1000} height={820} resizable>
      <Window.Content scrollable>
        <Tabs fluid>
          {groups.map(group => (
            <Tabs.Tab
              key={group.id}
              icon={group.icon}
              selected={tab === group.id}
              onClick={() => setTab(group.id)}>
              {group.label}
              {group.id !== 'management'
                && ` (${quests.filter(quest => quest.customer === group.id).length})`}
            </Tabs.Tab>
          ))}
        </Tabs>
        {tab === 'management' ? (
          <StatusPane />
        ) : (
          <Table className="CargoQuestConsole__cards">
            {rows.map(row => (
              <Table.Row key={row[0].ref}>
                {[0, 1].map(column => (
                  <Table.Cell key={column} width="50%" height="1px">
                    {row[column] && <QuestItem key={row[column].ref} quest={row[column]} />}
                  </Table.Cell>
                ))}
              </Table.Row>
            ))}
          </Table>
        )}
        {tab !== 'management' && visible.length === 0 && (
          <NoticeBox>В этой категории сейчас нет запросов.</NoticeBox>
        )}
      </Window.Content>
    </Window>
  );
};

const QuestItem = ({ quest }) => {
  const { act, data } = useBackend();
  const [showMenu, setShowMenu] = useState(false);
  const color = tierColors[quest.tier - 1];
  const manage = (action) => {
    act(action, { uid: quest.ref });
    setShowMenu(false);
  };
  return (
    <Section
      title={`Запрос от «${quest.target_departament}»`}
      className={`CargoQuestConsole__card CargoQuestConsole__card--${color}${quest.active ? ' CargoQuestConsole__card--active' : ''}`}
      height="100%"
      onClick={() => setShowMenu(!showMenu)}>
      <Stack vertical className="CargoQuestConsole__content">
        <Stack.Item>
          <Stack align="center" justify="space-between">
            <Stack.Item color={color} bold>
              {quest.department} · Тир {quest.tier}
            </Stack.Item>
            <Stack.Item>
              {!!quest.priority && <Icon name="star" color="yellow" mr={1} />}
              {!!quest.fast_bonus && (
                <Box inline title="Действует бонус за быструю доставку: +40%">
                  <Icon name="fire" color={color} />
                </Box>
              )}
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item grow>
          {quest.quests_items.map((task, index) => (
            <Stack key={index} align="center" mb={0.75}>
              <Stack.Item width="42px" shrink={0}>
                <img
                  className="CargoQuestConsole__image"
                  src={`data:image/png;base64,${task.image}`}
                  alt="" />
              </Stack.Item>
              <Stack.Item grow>{task.desc}</Stack.Item>
            </Stack>
          ))}
        </Stack.Item>
        <Stack.Item>
          <Box fontSize={1.15}>
            <b>Награда:</b> +{formatMoney(quest.reward)} кр.
          </Box>
          <Box mt={0.5}>
            <b>Осталось:</b> {formatTimer(quest.timer)}
            {' · '}{quest.active ? 'В работе' : 'Ожидает приёма'}
          </Box>
          {!!quest.extensions && (
            <Box color="average" mt={0.5}>
              Продление: −{quest.extensions * 10}%
            </Box>
          )}
        </Stack.Item>
      </Stack>
      {showMenu && (
        <Box className="CargoQuestConsole__menu" onClick={event => event.stopPropagation()}>
          <Button
            className="CargoQuestConsole__close"
            icon="times"
            aria-label="Закрыть меню запроса"
            onClick={() => setShowMenu(false)} />
          <Box bold fontSize={1.2} mb={2}>
            {quest.active ? 'Запрос уже в работе' : 'Выберите действие'}
          </Box>
          {!data.can_manage && (
            <Box color="average" mb={1}>Требуется доступ отдела снабжения.</Box>
          )}
          {quest.active ? (
            <>
              <Button
                icon="print"
                color="blue"
                disabled={!data.can_manage}
                onClick={() => manage('print_order')}>
                Печать
              </Button>
              <Button
                ml={1}
                icon="hourglass-half"
                color="orange"
                tooltip="Продлить на 5 минут, уменьшив награду на 10%. До пяти продлений."
                disabled={!data.can_manage || !quest.can_extend}
                onClick={() => manage('add_time')}>
                Отложить
              </Button>
            </>
          ) : (
            <>
              <Button
                icon="check"
                color="green"
                disabled={!data.can_manage}
                onClick={() => manage('activate')}>
                Принять
              </Button>
              <Button
                ml={1}
                icon="undo"
                color="blue"
                tooltip="Заменить один раз, сохранив тир запроса."
                disabled={!data.can_manage || !quest.can_reroll}
                onClick={() => manage('denied')}>
                Заменить
              </Button>
            </>
          )}
        </Box>
      )}
    </Section>
  );
};

const StatusPane = () => {
  const { data } = useBackend();
  const {
    cargo_money,
    timeleft,
    moving,
    at_station,
    completed,
    total_reward,
    sales = [],
  } = data;
  const status = moving
    ? `В пути (прибытие через ${timeleft})`
    : at_station ? 'Пристыкован к станции' : 'На Центральном командовании';
  return (
    <>
      <Section title="Статус">
        <LabeledList>
          <LabeledList.Item label="Бюджет снабжения">
            <AnimatedNumber value={cargo_money} format={formatMoney} /> кр.
          </LabeledList.Item>
          <LabeledList.Item label="Шаттл">{status}</LabeledList.Item>
          <LabeledList.Item label="Принято поставок">{completed}</LabeledList.Item>
          <LabeledList.Item label="Всего выплачено">{formatMoney(total_reward)} кр.</LabeledList.Item>
        </LabeledList>
      </Section>
      <Section title="Порядок выполнения">
        <Box mb={1}>
          Примите запрос, соберите его в одном ящике и упакуйте упаковочной бумагой.
          Через Alt+ЛКМ по маркировщику выберите заказчика и отметьте им посылку.
          Отправьте её грузовым шаттлом.
        </Box>
        <Box mb={1}>
          Один ящик выполняет один запрос. Проверяется непосредственное содержимое ящика:
          достаньте товары из сумок и других контейнеров. Не кладите внутрь бланк запроса.
        </Box>
        <Box mb={1}>
          Всегда доступны 4 запроса первого тира, 3 второго, 2 третьего и 1 четвёртого.
          Каждый содержит 1–3 разные позиции одного отдела и тира.
          При выполнении или истечении срока появляется новый запрос того же тира.
        </Box>
        <Box mb={1}>
          Множители за тир: ×1 / ×1,25 / ×1,5 / ×2.
          За полный заказ из двух позиций: ×1,1; из трёх: ×1,2.
          При неполной поставке оплачиваются полностью собранные позиции,
          бонус за количество позиций не применяется.
        </Box>
        <Box mb={1}>
          Быстрая доставка: +40%. Неверный заказчик: −20%.
          Каждый лишний предмет: −30%. Продление на 5 минут: −10% (до пяти раз).
          При приёме запроса срок бесплатно увеличивается на 5 минут.
        </Box>
        <Box>
          Запросы НТ и плазмы оплачиваются на счёт карго.
          Частные заказчики платят втрое больше: 60% получает карго,
          25% — станция, 15% — отдел-исполнитель (для шахтёров — карго).
        </Box>
      </Section>
      <Section title="Скидки за безупречные поставки">
        <Box mb={1}>
          Полная посылка без лишних вещей, отмеченная правильным заказчиком,
          открывает скидки в каталоге грузов. При быстрой доставке скидка удваивается.
          Скидки одного раздела не складываются: действует наибольшая полученная.
        </Box>
        {sales.length ? (
          <LabeledList>
            {sales.map(sale => (
              <LabeledList.Item key={sale.name} label={sale.name}>
                {sale.discount}%
              </LabeledList.Item>
            ))}
          </LabeledList>
        ) : <Box color="label">Скидки ещё не получены.</Box>}
      </Section>
    </>
  );
};
