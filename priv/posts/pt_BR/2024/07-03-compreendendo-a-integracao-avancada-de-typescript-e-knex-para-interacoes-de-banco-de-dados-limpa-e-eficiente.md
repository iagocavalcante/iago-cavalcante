%{
  title: "Compreendendo a Integração Avançada de TypeScript e Knex para Interações de Banco de Dados Limpa e Eficiente",
  author: "Iago Cavalcante",
  tags: ~w(typescript javascript),
  description: "Neste artigo, vamos discutir sobre a integração de TypeScript com banco de dados.",
  locale: "pt_BR",
  published: true
}
---

### Entendendo a Integração Avançada de TypeScript e Knex para Interações de Banco de Dados Limpas e Eficientes

Neste post, vamos nos aprofundar em um módulo TypeScript que utiliza técnicas avançadas para interagir com um banco de dados usando Knex.js, garantindo um manuseio de dados limpo e eficiente. Vamos detalhar o código, explicar os conceitos-chave e destacar as vantagens dessa abordagem.

#### Conceitos Utilizados

1. **Definições de Tipo TypeScript**:

   - Utilizamos definições de tipos avançadas do TypeScript e a biblioteca `type-fest` para garantir que nossos dados estejam em conformidade com formatos específicos. Isso melhora a segurança dos tipos e torna nosso código mais previsível e menos propenso a erros.

2. **Zod para Validação de Esquemas**:

   - Zod é uma biblioteca de declaração e validação de esquemas voltada para TypeScript. Ela permite que definamos esquemas para nossos modelos de dados e os validemos em tempo de execução.

3. **Knex.js para Interações com Banco de Dados**:

   - Knex.js é um construtor de consultas SQL para Node.js. Ele nos permite escrever consultas SQL de uma maneira programática e segura em termos de tipos.

4. **Funções Utilitárias para Conversão de Caso**:

   - Funções como `CamelToSnakeCase` e `SnakeToCamelCase` ajudam a converter as chaves dos objetos entre camelCase e snake\_case, garantindo consistência entre objetos JavaScript e registros de banco de dados.

5. **Type Guardso**:

   - Type Guards, como `isContactDto`, nos ajudam a garantir que nossos dados correspondam aos tipos esperados antes de realizar operações, aumentando a segurança em tempo de execução.

#### Explicando o Código

```typescript
import type { Knex } from 'knex';
import { CamelCase, CamelCasedProperties, SnakeCase, SnakeCasedProperties } from 'type-fest';
import { z } from 'zod';
import { knex } from '../db';

//#region Tools

type IterableGenericObject = { [k: string]: any };

function prefixObjectKeys(obj: { [k: string]: any }, prefix: string) {
    return Object.fromEntries(
        Object.entries(obj)
            .map(([k, v]) => [`${prefix}${k}`, v])
    );
}

export function CamelToSnakeCase<T extends string>(str: T): SnakeCase<T> {
    return str.toString()
        .split('')
        .map((char) => (char.toUpperCase() === char ? '_' : '') + char.toLowerCase())
        .join('') as SnakeCase<T>;
}

export function SnakeToCamelCase<T extends string>(str: T): CamelCase<T> {
    return str.toString()
        .split('')
        .map((char, i, a) => {
            if (i < 1) return char.toLowerCase();
            if (char === '_') return '';
            if (a[i - 1] === '_') return char.toUpperCase();
            return char.toLowerCase();
        })
        .join('') as CamelCase<T>;
}

export function ObjectToSnakeCasedProperties<
    I extends IterableGenericObject,
    O = SnakeCasedProperties<I>
>(obj: I, keyMap: Map<keyof I, keyof O> = new Map()) {
    return Object.fromEntries(
        Object.entries(obj)
            .map(([prop, value]) => [
                keyMap.get(prop) || CamelToSnakeCase(prop),
                value
            ] as const)
    ) as O;
}

export function ObjectToCamelCasedProperties<
    I extends IterableGenericObject,
    O = CamelCasedProperties<I>
>(obj: I, keyMap: Map<keyof I, keyof O> = new Map()) {
    return Object.fromEntries(
        Object.entries(obj)
            .map(([prop, value]) => [
                keyMap.get(prop) || SnakeToCamelCase(prop),
                value
            ] as const)
    ) as O;
}

//#endregion

//#region Contact domain

export const ContactSchema = z.object({
    id: z.number().positive().gt(0),
    firstName: z.string().min(1),
    lastName: z.string().min(1),
    phoneNumber: z.string().min(8).max(15),
});

export const ContactDtoSchema = ContactSchema.partial();
export const ContactUpsertDtoSchema = ContactSchema.omit({ id: true });

export type Contact = z.infer<typeof ContactSchema>;
export type ContactDto = z.infer<typeof ContactDtoSchema>;
export type ContactUpsertDto = z.infer<typeof ContactUpsertDtoSchema>;
export type ContactTableItem = SnakeCasedProperties<Contact>;

// Type guard example:
export function isContactDto(obj: Record<string, any>): obj is ContactDto {
    return ContactSchema.deepPartial().safeParse(obj).success;
}

export function isContactUpsertDto(obj: Record<string, any>): obj is ContactUpsertDto {
    return ContactUpsertDtoSchema.safeParse(obj).success;
}

//#endregion

//#region Contact repository

function getKnexInstance(knexInstance = knex) {
    return (knexInstance as Knex<ContactTableItem, ContactTableItem[]>)(`contacts`);
}

export const ContactFields = Object.freeze(Object.values(ContactSchema.keyof().Values));

export async function queryContact(contactWhere: ContactDto, fields = ContactFields, txn?: typeof knex): Promise<Contact | null> {
    if (!isContactDto(contactWhere)) {
        throw new Error('Invalid contact given');
    }

    const qb = fields.reduce((queryBuilder, col) => {
        return queryBuilder.select(`c.${col}`);
    }, getKnexInstance(txn));

    const where = prefixObjectKeys(ObjectToSnakeCasedProperties<ContactDto>(contactWhere), 'c.');

    const results = await qb
        .from<ContactTableItem, ContactTableItem[]>({ c: 'contacts' })
        .where(where);

    const [firstContactRow] = results;

    return firstContactRow
        ? ObjectToCamelCasedProperties<ContactTableItem>(firstContactRow)
        : null;
}

export async function insertContact(contact: ContactUpsertDto, txn?: typeof knex): Promise<number> {
    if (!isContactUpsertDto(contact)) {
        throw new Error('Invalid contact DTO given');
    }
    const [first] = await getKnexInstance(txn)
        .insert<SnakeCasedProperties<ContactUpsertDto>>(ObjectToSnakeCasedProperties<ContactUpsertDto>(contact))
        .returning('id') as Pick<ContactTableItem, 'id'>[];

    return first.id;
}

export async function updateContact(id: Contact['id'], contact: ContactUpsertDto, txn?: typeof knex): Promise<void> {
    if (!isContactUpsertDto(contact)) {
        throw new Error('Invalid contact DTO given');
    }
    await getKnexInstance(txn)
        .update(ObjectToSnakeCasedProperties<Omit<ContactDto, 'id'>>(contact))
        .where({ id });
}

export async function deleteContact(id: Contact['id'], txn?: typeof knex): Promise<void> {
    await getKnexInstance(txn).where({ id }).delete();
}

export async function listContacts(where = {} as ContactDto, fields = ContactFields, txn?: typeof knex): Promise<Contact[]> {
    const qb = fields.reduce((queryBuilder, col) => {
        return queryBuilder.select(`c.${col}`);
    }, getKnexInstance(txn));

    const results: ContactTableItem[] = await qb.where(where).from<ContactTableItem>({ c: 'contacts' });
    return results.map((record) => ObjectToCamelCasedProperties(record));
}

//#endregion
```

#### Vantagens Dessa Abordagem

1. **Segurança de Tipos**:

   - Ao usar TypeScript e Zod, garantimos que nossas estruturas de dados sejam estritamente tipadas. Isso reduz o risco de erros em tempo de execução e melhora a confiabilidade do código.

2. **Convenções de Nomenclatura Consistentes**:

   - As funções utilitárias `CamelToSnakeCase` e `SnakeToCamelCase` garantem que as chaves dos objetos sejam formatadas de forma consistente, facilitando a interação entre objetos JavaScript (camelCase) e bancos de dados SQL (snake\_case).

3. **Reusabilidade e Manutenibilidade**:

   - O design modular, com funções utilitárias e esquemas bem definidos, torna a base de código mais fácil de manter e expandir. Adicionar novas funcionalidades ou modificar as existentes torna-se mais simples.

4. **Separação Clara de Responsabilidades**:

   - O código é dividido em seções lógicas, como ferramentas, definições de domínio e funções de repositório. Essa separação torna o código mais fácil de entender e gerenciar.

5. **Validação Aprimorada**:

   - Usar Zod para validação de esquemas garante que os dados estejam em conformidade com os formatos esperados, detectando erros cedo no processo de desenvolvimento.

6. **Consultas de Banco de Dados Eficientes**:

   - Knex.js fornece um mecanismo poderoso de construção de consultas, e nossa abordagem garante que as consultas sejam seguras em termos de tipos e otimizadas para desempenho.

#### Conclusão

Esta abordagem aproveita as vantagens do TypeScript, Zod e Knex.js para criar uma camada de manipulação de dados robusta, manutenível e segura em termos de tipos. Garantindo convenções de nomenclatura consistentes e validação rigorosa, podemos construir aplicações confiáveis que são mais fáceis de desenvolver e manter.
